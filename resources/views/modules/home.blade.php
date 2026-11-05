@extends('layouts.app')
@section('title',$module['name'])
@section('content')
<div class="page-title-row"><div><div class="eyebrow">MANAGEMENT MODULE / {{ strtoupper($slug) }}</div><h1>{{ $module['name'] }}</h1><p>{{ $module['description'] }}</p></div><a href="{{ route('dashboard') }}" class="btn btn-outline">← Overview</a></div>
<div class="module-summary"><div class="module-large-badge">{{ $module['badge'] }}</div><div><small>MODULE REGISTERS</small><h2>{{ count($tables) }} related data registers</h2><p>Browse records, edit approved master data, and use guided workflows for transactional operations.</p></div></div>
@php $flows=\App\Support\SmsWorkflowCatalog::forModule($slug); $reports=\App\Http\Controllers\ReportsController::forModule($slug); @endphp
@if(count($reports)>0)<div class="table-card" style="margin-bottom:24px"><div class="table-card-head"><h3>Operational reports</h3><small>Read-only summaries from live institution records</small></div><div class="register-grid">@foreach($reports as $reportKey=>$report)
@if(\App\Support\SmsAccess::has($report['permission']))<a class="register-card" href="{{ route('report.show',$reportKey) }}"><span class="register-icon">▥</span><span><strong>{{ $report['label'] }}</strong><small>View report ↗</small></span></a>@endif
@endforeach</div></div>@endif
@if(count($flows)>0)<div class="table-card" style="margin-bottom:24px"><div class="table-card-head"><div><h3>Guided workflows</h3><small>Validated operational transactions with audit logs</small></div></div><div class="register-grid">@foreach($flows as $flowKey=>$flow)
@if(\App\Support\SmsAccess::has($flow['permission']))<a class="register-card" href="{{ route('workflow.show',$flowKey) }}"><span class="register-icon">↗</span><span><strong>{{ $flow['label'] }}</strong><small>{{ $flow['description'] }}</small></span><span class="register-arrow">→</span></a>@endif
@endforeach</div></div>@endif
<div class="table-card"><div class="table-card-head"><h3>Module data registers</h3><span class="badge">Tenant-scoped</span></div><div class="register-grid">@forelse($tables as $table)<a class="register-card" href="{{ route('module.records',[$slug,$table['name']]) }}"><span class="register-icon">▤</span><span><strong>{{ \Illuminate\Support\Str::headline($table['name']) }}</strong><small>{{ number_format($table['count']) }} records</small></span><span class="register-arrow">↗</span></a>@empty<div class="empty-state">No register tables were found. Run the database migrations.</div>@endforelse</div></div>
@endsection
