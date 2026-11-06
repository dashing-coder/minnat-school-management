<?php
namespace App\Http\Controllers;
use App\Support\ModuleCatalog;
use App\Support\SmsAccess;
use App\Support\SmsTablePolicy;
use App\Support\SmsAudit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;
use Symfony\Component\HttpFoundation\StreamedResponse;
final class ModulesController {
    private function authorizeModule(string $slug, ?string $table=null): array {
        $module=ModuleCatalog::find($slug); abort_unless($module,404);
        SmsAccess::require($module['permission']);
        if ($table!==null) { abort_unless(ModuleCatalog::includesTable($slug,$table),404); abort_unless(Schema::hasTable($table),404); SmsTablePolicy::requireRead($table); }
        return $module;
    }
    public function home(string $slug) {
        $module=$this->authorizeModule($slug);
        $tables=[];
        foreach ($module['tables'] as $table) {
            if (!Schema::hasTable($table) || !SmsTablePolicy::canRead($table)) continue;
            $tables[]=['name'=>$table,'count'=>SmsAccess::scopedQuery($table)->count()];
        }
        return view('modules.home',compact('slug','module','tables'));
    }
    public function records(Request $request,string $slug,string $table) {
        $module=$this->authorizeModule($slug,$table);
        $columns=Schema::getColumnListing($table);
        $display=SmsTablePolicy::displayColumns($table,$columns);
        $q=SmsAccess::scopedQuery($table);
        $search=trim((string)$request->query('q',''));
        $searchField=collect(['name','title','code','admission_no','invoice_no','application_no','journal_no','employee_no','email'])->first(fn($x)=>in_array($x,$columns,true));
        if ($search!=='' && $searchField!==null) {
            $q->where($searchField,'like','%'.str_replace(['%','_'],['\\%','\\_'],$search).'%');
        }
        $records=$q->orderByDesc($table.'.id')->paginate(15)->withQueryString();
        return view('modules.records',compact('slug','table','module','columns','display','records','search'));
    }
    public function export(string $slug,string $table): StreamedResponse {
        $this->authorizeModule($slug,$table); SmsAccess::require('reports.export');
        // Export is deliberately restricted to records already scoped to the current institution.
        $columns=SmsTablePolicy::exportColumns($table);
        SmsAudit::record('register.export',$table,SmsAccess::institutionId());
        $filename=$table.'-institution-'.SmsAccess::institutionId().'.csv';
        return response()->streamDownload(function () use($table,$columns) {
            $stream=fopen('php://output','w'); fputcsv($stream,$columns);
            $query=SmsAccess::scopedQuery($table)->orderBy('id');
            // Deliberately cap admin prototype exports; production needs async job & audit.
            $rows=$query->limit(10000)->cursor();
            foreach($rows as $row) {
                    $cells=[];
                    foreach($columns as $col){
                        $s=(string)($row->{$col} ?? '');
                        // Neutralize CSV formula injection, including whitespace-prefixed expressions.
                        if (preg_match('/^\\s*[=+@-]/u',$s)) $s="'".$s;
                        $cells[]=$s;
                    }
                    fputcsv($stream,$cells);
            }
            fclose($stream);
        },$filename,['Content-Type'=>'text/csv; charset=UTF-8']);
    }
}
