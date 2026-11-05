<?php
namespace App\Http\Controllers;
use Illuminate\Support\Facades\DB;

final class CertificateVerifyController
{
    public function show(string $token)
    {
        // Public response intentionally exposes only certificate status, document type
        // and institution name; no student's name, DOB or sensitive identifiers.
        $row=DB::table('issued_certificates as c')
            ->join('certificate_templates as t',function($j){$j->on('t.id','=','c.certificate_template_id')->on('t.institution_id','=','c.institution_id');})
            ->join('institutions as i','i.id','=','c.institution_id')
            ->where('c.verification_token',$token)->where('c.status','issued')
            ->where('i.status','active')->whereNull('i.deleted_at')
            ->select('c.certificate_no','c.issued_on','t.name as template','i.name as institution')->first();
        return response()->view('certificate-verification',['certificate'=>$row],$row?200:404)
            ->header('X-Robots-Tag','noindex, nofollow')->header('Cache-Control','no-store');
    }
}
