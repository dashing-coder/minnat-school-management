@extends('layouts.app')
@section('title',$config['label'])
@section('content')
<div class="page-title-row"><div><div class="eyebrow">{{ strtoupper($config['module']) }} / ANALYTICS</div><h1>{{ $config['label'] }}</h1><p>Institution-scoped operational reporting. Generated {{ now()->format('j M Y, g:i A') }}.</p></div><div class="row-actions"><a class="btn btn-outline" href="{{ route('module.home',$config['module']) }}">← Back</a>@if(\App\Support\SmsAccess::has('reports.export'))<a class="btn btn-dark" href="{{ route('report.export',$report) }}">↓ Export report CSV</a>@endif</div></div>
<div class="table-card"><div class="table-card-head"><h3>Report results</h3><span class="badge">{{ number_format($rows->count()) }} records shown</span></div><div class="table-scroll"><table class="data-table"><thead><tr>@foreach($columns as $column)<th>{{ $column }}</th>@endforeach</tr></thead><tbody>@forelse($rows as $row)<tr>@foreach(array_values((array)$row) as $value)<td>{{ is_scalar($value)?$value:'—' }}</td>@endforeach</tr>@empty<tr><td colspan="{{ count($columns) }}"><div class="empty-state">No data available for this report.</div></td></tr>@endforelse</tbody></table></div></div>
@if($note)<div class="info-hint">{{ $note }}</div>@endif
@endsection
