<?php
include "conexao.php";

if ($_SERVER["REQUEST_METHOD"] == "GET") {

    $usuarioId = intval($_GET["usuario_id"] ?? 0);

    $sql = "SELECT producoes.*, usuarios.nome AS nome_produtor
            FROM producoes
            JOIN usuarios ON usuarios.id = producoes.usuario_id";

    if ($usuarioId > 0) {
        $sql .= " WHERE producoes.usuario_id = $usuarioId";
    }

    $sql .= " ORDER BY producoes.id DESC";

    $resultado = $conexao->query($sql);
    $lista = [];

    while ($linha = $resultado->fetch_assoc()) {
        $linha["quantidade"] = intval($linha["quantidade"]);
        $linha["estoque"] = intval($linha["estoque"]);
        $linha["valor_unitario"] = floatval($linha["valor_unitario"]);
        $linha["total"] = floatval($linha["total"]);
        $linha["comissao"] = floatval($linha["comissao"]);
        $linha["valor_comissao"] = floatval($linha["valor_comissao"]);
        $linha["valor_final"] = floatval($linha["valor_final"]);
        $lista[] = $linha;
    }

    echo json_encode($lista);
    exit;
}

$usuarioId = intval($_POST["usuario_id"] ?? 0);
$quantidade = intval($_POST["quantidade"] ?? 0);
$valorUnitario = floatval($_POST["valor_unitario"] ?? 0);

if ($usuarioId <= 0 || $quantidade <= 0 || $valorUnitario <= 0) {
    die(json_encode(["erro" => "Informe a quantidade e o valor unitario"]));
}

$config = $conexao->query("SELECT comissao FROM configuracoes WHERE id = 1")->fetch_assoc();
$comissao = floatval($config["comissao"]);

$total = $quantidade * $valorUnitario;
$valorComissao = $total * $comissao / 100;
$valorFinal = $total - $valorComissao;

$sql = "INSERT INTO producoes
        (usuario_id, quantidade, estoque, valor_unitario, total, comissao, valor_comissao, valor_final)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
$comando = $conexao->prepare($sql);
$comando->bind_param("iiiddddd", $usuarioId, $quantidade, $quantidade, $valorUnitario, $total, $comissao, $valorComissao, $valorFinal);

if ($comando->execute()) {
    echo json_encode([
        "id" => $conexao->insert_id,
        "usuario_id" => $usuarioId,
        "quantidade" => $quantidade,
        "estoque" => $quantidade,
        "valor_unitario" => $valorUnitario,
        "total" => $total,
        "comissao" => $comissao,
        "valor_comissao" => $valorComissao,
        "valor_final" => $valorFinal
    ]);
} else {
    echo json_encode(["erro" => "Erro ao registrar a producao"]);
}

$conexao->close();
