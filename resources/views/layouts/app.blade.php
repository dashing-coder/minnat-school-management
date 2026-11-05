<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <title>@yield('title','Dashboard') · CampusSphere</title>
  <link rel="stylesheet" href="{{ asset('css/app.css') }}">
</head>
<body class="app-body">
<div class="app-shell">
  <aside class="sidebar" id="sidebar">
    <a href="{{ \App\Support\SmsAccess::has('dashboard.view') ? route('dashboard') : route('portal') }}" class="brand"><span class="brand-mark">C</span><span>Campus<span class="brand-accent">Sphere</span><small>EDUCATION MANAGEMENT</small></span></a>
    <div class="sidebar-caps">WORKSPACE</div>
    @if(\App\Support\SmsAccess::has('dashboard.view'))<a class="nav-link {{ request()->routeIs('dashboard')?'active':'' }}" href="{{ route('dashboard') }}"><span class="nav-symbol">▦</span><span>Overview</span></a>@endif
    <a class="nav-link {{ request()->routeIs('portal')?'active':'' }}" href="{{ route('portal') }}"><span class="nav-symbol">◉</span><span>My Portal</span></a>
    @if(\App\Support\SmsAccess::has('students.view'))
       <a class="nav-link {{ request()->routeIs('students.*')?'active':'' }}" href="{{ route('students.index') }}"><span class="nav-symbol">♧</span><span>Student Directory</span></a>
    @endif
    @if(\App\Support\SmsAccess::has('memberships.manage') && \App\Support\SmsAccess::has('roles.manage'))
    <a class="nav-link {{ request()->routeIs('users.*')?'active':'' }}" href="{{ route('users.index') }}"><span class="nav-symbol">♙</span><span>Users & Roles</span></a>
    @endif
    <div class="sidebar-caps">MANAGEMENT MODULES</div>
    @foreach(\App\Support\ModuleCatalog::all() as $moduleKey=>$module)
      @if(\App\Support\SmsAccess::has($module['permission']))
      <a class="nav-link {{ request()->route('slug')===$moduleKey?'active':'' }}" href="{{ route('module.home',$moduleKey) }}">
        <span class="nav-symbol nav-initial">{{ $module['badge'] }}</span><span>{{ $module['name'] }}</span>
      </a>
      @endif
    @endforeach
    <div class="sidebar-bottom"><span class="pulse"></span> Local Laravel development <small>Laravel + MySQL · Core workflows</small></div>
  </aside>
  <div class="main-shell">
    <header class="topbar">
      <div class="topbar-left"><button type="button" class="mobile-nav-btn" id="menuButton" aria-label="Toggle menu">☰</button><span class="breadcrumb-top">Workspace <span>›</span> {{ $activeInstitution->institution_name }}</span></div>
      <div class="topbar-right">
         <a class="institution-chip" href="{{ route('institution.choose') }}"><span class="institution-dot"></span>{{ $activeInstitution->institution_type }} <span class="chevron">⌄</span></a>
         <span class="topbar-user"><span class="avatar">{{ strtoupper(substr(auth()->user()->name,0,1)) }}</span><span>{{ auth()->user()->name }}</span></span>
         <form method="post" action="{{ route('logout') }}">@csrf <button class="topbar-logout" title="Sign out" type="submit">Log out</button></form>
      </div>
    </header>
    <main class="page-content">
      @if(session('success')) <div class="alert success">✓ {{ session('success') }}</div> @endif
      @if($errors->any()) <div class="alert error"><strong>Please review:</strong> {{ $errors->first() }}</div> @endif
      @yield('content')
      <footer class="page-footer"><span>© {{ date('Y') }} CampusSphere ERP</span><span>Expanded development build · Production QA pending</span></footer>
    </main>
  </div>
</div>
<script>
  document.getElementById('menuButton')?.addEventListener('click',()=>document.getElementById('sidebar')?.classList.toggle('mobile-open'));
</script>
@stack('scripts')
</body></html>
