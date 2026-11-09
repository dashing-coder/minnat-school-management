@extends('layouts.app')
@section('title',$def['label'])
@section('content')
<div class="page-title-row"><div><div class="eyebrow">{{ strtoupper($def['module']) }} / CONTROLLED WORKFLOW</div><h1>{{ $def['label'] }}</h1><p>{{ $def['description'] }}</p></div><a class="btn btn-outline" href="{{ route('module.home',$def['module']) }}">← Module</a></div>
<form data-prevent-double-submit="true" method="post" action="{{ route('workflow.store',$flow) }}" class="table-card" autocomplete="off">
@csrf
<div class="module-form-grid">
@foreach($def['fields'] as $name=>$spec)
<div class="form-field"><label for="f-{{ $name }}">{{ \Illuminate\Support\Str::headline($name) }} @if(!str_starts_with($spec[0],'optional')) <span aria-hidden="true">*</span>@endif</label>
@php $value=old($name, $spec[0]==='date'?date('Y-m-d'):''); @endphp
@if($spec[0]==='select')
<select name="{{ $name }}" id="f-{{ $name }}" @error($name) aria-invalid="true" aria-describedby="error-{{ $name }}" @enderror required><option value="">— Choose a record —</option>
@foreach($options[$name]??[] as $row)<option value="{{ $row['id'] }}" @selected((string)$value===(string)$row['id'])>{{ $row['label'] }}</option>@endforeach</select>
@if(empty($options[$name]))<small>No accessible records available. Create the prerequisite records first.</small>@endif
@elseif($spec[0]==='choices')
<select name="{{ $name }}" id="f-{{ $name }}" @error($name) aria-invalid="true" aria-describedby="error-{{ $name }}" @enderror required><option value="">Choose</option>
@foreach($spec[1] as $choice=>$label)<option value="{{ $choice }}" @selected($value===$choice)>{{ $label }}</option>@endforeach</select>
@elseif(in_array($spec[0],['optional_text']))
<textarea name="{{ $name }}" id="f-{{ $name }}" @error($name) aria-invalid="true" aria-describedby="error-{{ $name }}" @enderror rows="3">{{ $value }}</textarea>
@else
<input name="{{ $name }}" id="f-{{ $name }}" @error($name) aria-invalid="true" aria-describedby="error-{{ $name }}" @enderror type="{{ in_array($spec[0],['date','time'])?$spec[0]:(in_array($spec[0],['number','money','optional_number','integer','percent'])?'number':'text') }}" 
@if(in_array($spec[0],['number','money','optional_number','percent'])) step="0.01" @elseif($spec[0]==='integer') step="1" @endif
@if(!str_starts_with($spec[0],'optional')) required @endif value="{{ $value }}" maxlength="190">
@endif
@error($name)<small class="field-error" id="error-{{ $name }}">{{ $message }}</small>@enderror
</div>
@endforeach
</div>
<div class="form-action-bar"><button type="submit" class="btn btn-primary">Submit workflow</button><a href="{{ route('module.home',$def['module']) }}" class="btn btn-outline">Cancel</a></div>
</form>
<div class="info-hint">Institution-scoped records · Audit trail · Validated workflow · Some external settlement and notification features remain unavailable.</div>
@endsection
