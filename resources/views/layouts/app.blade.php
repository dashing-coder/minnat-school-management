<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="color-scheme" content="light">
  <title>@yield('title','Dashboard') · CampusSphere</title>
  <link rel="stylesheet" href="{{ asset('css/app.css') }}">
  <script src="{{ asset('js/erp-ui.js') }}" defer></script>
</head>
<body class="app-body">
<a href="#main-content" class="skip-link">Skip to main content</a>
<div id="navBackdrop" class="nav-backdrop" hidden aria-hidden="true"></div>
<div class="app-shell">
  <aside class="sidebar" id="sidebar" aria-label="Workspace navigation">
    <a href="{{ \App\Support\SmsAccess::has('dashboard.view') ? route('dashboard') : route('portal') }}" class="brand"><span class="brand-mark" aria-hidden="true">C</span><span>Campus<span class="brand-accent">Sphere</span><small>EDUCATION MANAGEMENT</small></span></a>
    <label for="moduleNavSearch" class="sidebar-search-label">Find a module</label>
    <input type="search" id="moduleNavSearch" class="sidebar-search" placeholder="Search modules…" autocomplete="off" aria-controls="moduleNavList">
    <nav aria-label="Main workspace">
      <div class="sidebar-caps">WORKSPACE</div>
      @if(\App\Support\SmsAccess::has('dashboard.view'))
        <a class="nav-link {{ request()->routeIs('dashboard')?'active':'' }}" href="{{ route('dashboard') }}" @if(request()->routeIs('dashboard')) aria-current="page" @endif><span class="nav-symbol" aria-hidden="true">▦</span><span>Overview</span></a>
      @endif
      <a class="nav-link {{ request()->routeIs('portal')?'active':'' }}" href="{{ route('portal') }}" @if(request()->routeIs('portal')) aria-current="page" @endif><span class="nav-symbol" aria-hidden="true">◉</span><span>My Portal</span></a>
      @if(\App\Support\SmsAccess::has('students.view'))
        <a class="nav-link {{ request()->routeIs('students.*')?'active':'' }}" href="{{ route('students.index') }}" @if(request()->routeIs('students.*')) aria-current="page" @endif><span class="nav-symbol" aria-hidden="true">♧</span><span>Student Directory</span></a>
      @endif
      @if(\App\Support\SmsAccess::has('memberships.manage') && \App\Support\SmsAccess::has('roles.manage'))
        <a class="nav-link {{ request()->routeIs('users.*')?'active':'' }}" href="{{ route('users.index') }}" @if(request()->routeIs('users.*')) aria-current="page" @endif><span class="nav-symbol" aria-hidden="true">♙</span><span>Users &amp; Roles</span></a>
      @endif
      <div class="sidebar-caps">MANAGEMENT MODULES</div>
      <div id="moduleNavList">
      @foreach(\App\Support\ModuleCatalog::all() as $moduleKey=>$module)
        @if(\App\Support\SmsAccess::has($module['permission']))
          <a data-nav-module class="nav-link {{ request()->route('slug')===$moduleKey?'active':'' }}" href="{{ route('module.home',$moduleKey) }}" @if(request()->route('slug')===$moduleKey) aria-current="page" @endif><span class="nav-symbol nav-initial" aria-hidden="true">{{ $module['badge'] }}</span><span>{{ $module['name'] }}</span></a>
        @endif
      @endforeach
      </div>
      <p class="nav-no-results" id="moduleNavEmpty" role="status" hidden>No matching modules.</p>
    </nav>
    <div class="sidebar-bottom"><span class="pulse" aria-hidden="true"></span> Local Laravel development <small>Laravel + MySQL · Core workflows</small></div>
  </aside>
  <div class="main-shell">
    <header class="topbar">
      <div class="topbar-left">
        <button type="button" class="mobile-nav-btn" id="menuButton" aria-label="Open navigation menu" aria-controls="sidebar" aria-expanded="false">☰</button>
        <span class="breadcrumb-top">Workspace <span aria-hidden="true">›</span> {{ $activeInstitution->institution_name }}</span>
      </div>
      <div class="topbar-right">
        <a class="institution-chip" href="{{ route('institution.choose') }}" aria-label="Switch institution; current institution {{ $activeInstitution->institution_name }}"><span class="institution-dot" aria-hidden="true"></span>{{ $activeInstitution->institution_name }} <span class="chevron" aria-hidden="true">⌄</span></a>
        <span class="topbar-user"><span class="avatar" aria-hidden="true">{{ strtoupper(substr(auth()->user()->name,0,1)) }}</span><span>{{ auth()->user()->name }}</span></span>
        <form method="post" action="{{ route('logout') }}">@csrf <button class="topbar-logout" title="Sign out" type="submit">Log out</button></form>
      </div>
    </header>
    <main class="page-content" id="main-content" tabindex="-1">
      @if(session('success')) <div class="alert success" role="status">✓ {{ session('success') }}</div> @endif
      @if($errors->any())
        <div class="alert error" role="alert" tabindex="-1" id="validation-summary">
          <strong>Please correct {{ $errors->count() }} {{ \Illuminate\Support\Str::plural('field',$errors->count()) }}:</strong>
          <ul>@foreach($errors->all() as $message)<li>{{ $message }}</li>@endforeach</ul>
        </div>
      @endif
      @yield('content')
      <footer class="page-footer"><span>© {{ date('Y') }} CampusSphere ERP</span><span>Development build · Production QA pending</span></footer>
    </main>
  </div>
</div>
@stack('scripts')
</body>
</html>
