<?php
include "conexao.php";

$nome = $_POST["nome"] ?? "";
$email = $_POST["email"] ?? "";
$senha = $_POST["senha"] ?? "";
$perfil = $_POST["perfil"] ?? "";

if ($nome == "" || $email == "" || $senha == "" || $perfil == "") {
    die(json_encode(["erro" => "Preencha todos os campos"]));
}

if ($perfil != "produtor" && $perfil != "vendedor") {
    die(json_encode(["erro" => "Perfil invalido"]));
}

$sql = "SELECT id FROM usuarios WHERE email = ?";
$comando = $conexao->prepare($sql);
$comando->bind_param("s", $email);
$comando->execute();
$resultado = $comando->get_result();

if ($resultado->fetch_assoc()) {
    die(json_encode(["erro" => "Este e-mail ja esta cadastrado"]));
}

$senhaCriptografada = password_hash($senha, PASSWORD_DEFAULT);

$sql = "INSERT INTO usuarios (nome, email, senha, perfil) VALUES (?, ?, ?, ?)";
$comando = $conexao->prepare($sql);
$comando->bind_param("ssss", $nome, $email, $senhaCriptografada, $perfil);

if ($comando->execute()) {
    echo json_encode([
        "id" => $conexao->insert_id,
        "nome" => $nome,
        "email" => $email,
        "perfil" => $perfil
    ]);
} else {
    echo json_encode(["erro" => "Erro ao cadastrar"]);
}

$conexao->close();
