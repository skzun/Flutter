<?php
include "conexao.php";

if ($_SERVER["REQUEST_METHOD"] == "GET") {
    $config = $conexao->query("SELECT comissao FROM configuracoes WHERE id = 1")->fetch_assoc();
    echo json_encode(["comissao" => floatval($config["comissao"])]);
    exit;
}

$usuarioId = intval($_POST["usuario_id"] ?? 0);
$comissao = floatval($_POST["comissao"] ?? -1);

if ($comissao < 0 || $comissao > 100) {
    die(json_encode(["erro" => "A comissao deve ficar entre 0 e 100"]));
}

$sql = "SELECT perfil FROM usuarios WHERE id = ?";
$comando = $conexao->prepare($sql);
$comando->bind_param("i", $usuarioId);
$comando->execute();
$usuario = $comando->get_result()->fetch_assoc();

if (!$usuario || $usuario["perfil"] != "gerente") {
    die(json_encode(["erro" => "Apenas o gerente pode alterar a comissao"]));
}

$sql = "UPDATE configuracoes SET comissao = ? WHERE id = 1";
$comando = $conexao->prepare($sql);
$comando->bind_param("d", $comissao);

if ($comando->execute()) {
    echo json_encode(["comissao" => $comissao]);
} else {
    echo json_encode(["erro" => "Erro ao salvar a comissao"]);
}

$conexao->close();
