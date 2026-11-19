<?php
include "conexao.php";

$usuarioId = intval($_POST["usuario_id"] ?? 0);
$producaoId = intval($_POST["producao_id"] ?? 0);
$quantidade = intval($_POST["quantidade"] ?? 0);

if ($usuarioId <= 0 || $producaoId <= 0 || $quantidade <= 0) {
    die(json_encode(["erro" => "Informe a quantidade de trufas"]));
}

$sql = "SELECT perfil FROM usuarios WHERE id = ?";
$comando = $conexao->prepare($sql);
$comando->bind_param("i", $usuarioId);
$comando->execute();
$usuario = $comando->get_result()->fetch_assoc();

if (!$usuario || $usuario["perfil"] != "vendedor") {
    die(json_encode(["erro" => "Apenas o vendedor pode comprar"]));
}

$sql = "SELECT producoes.*, usuarios.nome AS nome_produtor
        FROM producoes
        JOIN usuarios ON usuarios.id = producoes.usuario_id
        WHERE producoes.id = ?";
$comando = $conexao->prepare($sql);
$comando->bind_param("i", $producaoId);
$comando->execute();
$producao = $comando->get_result()->fetch_assoc();

if (!$producao) {
    die(json_encode(["erro" => "Producao nao encontrada"]));
}

if ($quantidade > $producao["estoque"]) {
    die(json_encode(["erro" => "Estoque insuficiente"]));
}

$config = $conexao->query("SELECT comissao FROM configuracoes WHERE id = 1")->fetch_assoc();
$comissao = floatval($config["comissao"]);

$valorUnitario = floatval($producao["valor_unitario"]);
$total = $quantidade * $valorUnitario;
$valorComissao = $total * $comissao / 100;
$valorFinal = $total + $valorComissao;

$sql = "INSERT INTO compras
        (producao_id, usuario_id, quantidade, valor_unitario, total, comissao, valor_comissao, valor_final)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
$comando = $conexao->prepare($sql);
$comando->bind_param("iiiddddd", $producaoId, $usuarioId, $quantidade, $valorUnitario, $total, $comissao, $valorComissao, $valorFinal);
$comando->execute();

$compraId = $conexao->insert_id;

$sql = "UPDATE producoes SET estoque = estoque - ? WHERE id = ?";
$comando = $conexao->prepare($sql);
$comando->bind_param("ii", $quantidade, $producaoId);
$comando->execute();

echo json_encode([
    "id" => $compraId,
    "producao_id" => $producaoId,
    "nome_produtor" => $producao["nome_produtor"],
    "quantidade" => $quantidade,
    "valor_unitario" => $valorUnitario,
    "total" => $total,
    "comissao" => $comissao,
    "valor_comissao" => $valorComissao,
    "valor_final" => $valorFinal
]);

$conexao->close();
