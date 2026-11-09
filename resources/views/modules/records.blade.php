{{--
    Register Records List
    Developer: Dashing Coder
--}}
@extends('layouts.app')

@section('title', \Illuminate\Support\Str::headline($table))

@section('content')
@php
    $canEdit   = \App\Http\Controllers\RegisterEditorController::canEdit($slug, $table);
    $canExport = \App\Support\SmsTablePolicy::canExport($table);
    $colspan   = max(1, count($display) + ($canEdit ? 1 : 0));
@endphp

<div class="page-title-row">
    <div>
        <div class="eyebrow">
            <a href="{{ route('module.home', $slug) }}">{{ strtoupper($module['name']) }}</a> / DATA REGISTER
        </div>
        <h1>{{ \Illuminate\Support\Str::headline($table) }}</h1>
        <p>Records for {{ $activeInstitution->institution_name }} only.</p>
    </div>

    <div class="row-actions">
        @if($canEdit)
            <a class="btn btn-primary" href="{{ route('register.create', [$slug, $table]) }}">+ New record</a>
        @endif
        <a href="{{ route('module.home', $slug) }}" class="btn btn-outline">← Back</a>
        @if($canExport)
            <a class="btn btn-dark" href="{{ route('module.export', [$slug, $table]) }}">↓ Export CSV</a>
        @endif
    </div>
</div>

<div class="table-card">
    <div class="table-card-head">
        <div>
            <h3>Records</h3>
            <small>{{ number_format($records->total()) }} matching records</small>
        </div>

        <form class="search-form" method="get">
            <label class="sr-only" for="registerSearch">Search records</label>
            <input id="registerSearch" type="search" name="q" placeholder="Search records..." value="{{ $search }}">
            <button class="btn btn-primary" type="submit">Search</button>
            @if($search)
                <a class="clear-link" href="{{ route('module.records', [$slug, $table]) }}">Clear</a>
            @endif
        </form>
    </div>

    <div class="table-scroll" tabindex="0" role="region" aria-label="Module records table">
        <table class="data-table">
            <thead>
                <tr>
                    @foreach($display as $col)
                        <th scope="col">{{ \Illuminate\Support\Str::headline($col) }}</th>
                    @endforeach
                    @if($canEdit)
                        <th scope="col">Action</th>
                    @endif
                </tr>
            </thead>
            <tbody>
                @forelse($records as $record)
                    <tr>
                        @foreach($display as $col)
                            @php
                                $v = $record->{$col} ?? null;
                                $text = is_scalar($v) ? (string) $v : json_encode($v);
                            @endphp
                            <td title="{{ $text }}">{{ \Illuminate\Support\Str::limit($text, 66) }}</td>
                        @endforeach
                        @if($canEdit)
                            <td>
                                <a class="inline-link" href="{{ route('register.edit', [$slug, $table, $record->id]) }}">Edit</a>
                            </td>
                        @endif
                    </tr>
                @empty
                    <tr>
                        <td colspan="{{ $colspan }}">
                            <div class="empty-state">
                                @if($search)
                                    No records match your search. Clear the filter to see all records.
                                @else
                                    No records yet in this register.
                                @endif
                            </div>
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="pagination-bar">{{ $records->links('pagination.simple') }}</div>
</div>

<div class="info-hint">
    Master data may be edited only when explicitly authorized. Financial transactions and academic results require guided workflows.
</div>
@endsection