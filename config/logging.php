<?php
return [
    'default'=>env('LOG_CHANNEL','stack'),
    'channels'=>[
       'stack'=>['driver'=>'stack','channels'=>explode(',',env('LOG_STACK','single')),'ignore_exceptions'=>false],
       'single'=>['driver'=>'single','path'=>storage_path('logs/laravel.log'),'level'=>env('LOG_LEVEL','debug')],
       'stderr'=>['driver'=>'monolog','level'=>env('LOG_LEVEL','debug'),'handler'=>Monolog\Handler\StreamHandler::class,'with'=>['stream'=>'php://stderr']],
    ],
];
