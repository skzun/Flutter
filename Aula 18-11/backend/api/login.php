<?php
include "conexao.php";

$email = $_POST["email"] ?? "";
$senha = $_POST["senha"] ?? "";

if ($email == "" || $senha == "") {
    die(json_encode(["erro" => "Preencha e-mail e senha"]));
}

$sql = "SELECT * FROM usuarios WHERE email = ?";
$comando = $conexao->prepare($sql);
$comando->bind_param("s", $email);
$comando->execute();
$resultado = $comando->get_result();
$usuario = $resultado->fetch_assoc();

if (!$usuario || !password_verify($senha, $usuario["senha"])) {
    die(json_encode(["erro" => "E-mail ou senha incorretos"]));
}

echo json_encode([
    "id" => $usuario["id"],
    "nome" => $usuario["nome"],
    "email" => $usuario["email"],
    "perfil" => $usuario["perfil"]
]);

$conexao->close();
