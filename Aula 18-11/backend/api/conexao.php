<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=utf-8");

$host = "localhost";
$usuario = "root";
$senha = "";
$banco = "trufas_db";

$conexao = new mysqli($host, $usuario, $senha, $banco);

if ($conexao->connect_error) {
    die(json_encode(["erro" => "Falha na conexao: " . $conexao->connect_error]));
}

$conexao->set_charset("utf8");
