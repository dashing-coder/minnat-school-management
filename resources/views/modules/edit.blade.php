@extends('layouts.app')
@section('title',($record?'Edit ':'New ').\Illuminate\Support\Str::headline($table))
@section('content')
<div class="page-title-row"><div><div class="eyebrow">{{ strtoupper($slug) }} / MASTER DATA</div><h1>{{ $record?'Edit':'Add' }} {{ \Illuminate\Support\Str::headline($table) }}</h1><p>Authorized master-data changes are recorded in your institution audit log.</p></div><a class="btn btn-outline" href="{{ route('module.records',[$slug,$table]) }}">← Cancel</a></div>
<form class="table-card" method="post" action="{{ $record ? route('register.update',[$slug,$table,$record->id]) : route('register.store',[$slug,$table]) }}">
@csrf @if($record) @method('PUT') @endif
<div class="module-form-grid">
@foreach($fields as $name=>$meta)
<div class="form-field"><label for="f-{{ $name }}">{{ \Illuminate\Support\Str::headline($name) }}@if(!$meta['nullable']) <span aria-hidden="true">*</span>@endif</label>
@php $v=old($name,$record->{$name}??null); $t=$meta['type']; @endphp
@if(isset($options[$name]))
<select id="f-{{ $name }}" name="{{ $name }}" @required(!$meta['nullable'])><option value="">Select</option>@foreach($options[$name] as $opt)<option value="{{ $opt['id'] }}" @selected((string)$v===(string)$opt['id'])>{{ $opt['label'] }}</option>@endforeach</select>
@elseif($t==='boolean')
<select id="f-{{ $name }}" name="{{ $name }}"><option value="1" @selected((string)$v==='1')>Yes</option><option value="0" @selected((string)$v==='0')>No</option></select>
@elseif(in_array($t,['text','longText']))
<textarea id="f-{{ $name }}" name="{{ $name }}" rows="3" @required(!$meta['nullable'])>{{ $v }}</textarea>
@else
<input id="f-{{ $name }}" name="{{ $name }}" type="{{ $t==='date'?'date':(in_array($t,['dateTime'],true)?'datetime-local':($t==='decimal'||str_contains($t,'Integer')||$t==='integer'?'number':'text')) }}" @if($t==='decimal') step="0.01" @elseif(str_contains($t,'Integer')||$t==='integer') step="1" @endif value="{{ $v }}" @required(!$meta['nullable']) maxlength="{{ $meta['max'] }}" />
@endif
@error($name)<small style="color:#c62828">{{ $message }}</small>@enderror</div>
@endforeach
</div><div class="form-action-bar"><button class="btn btn-primary" type="submit">{{ $record?'Save changes':'Create record' }}</button><a class="btn btn-outline" href="{{ route('module.records',[$slug,$table]) }}">Cancel</a></div>
</form>
@endsection
