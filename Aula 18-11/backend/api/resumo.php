<?php
include "conexao.php";

$produzido = $conexao->query("SELECT SUM(quantidade) AS total FROM producoes")->fetch_assoc();
$vendido = $conexao->query("SELECT SUM(quantidade) AS total FROM compras")->fetch_assoc();
$lucro = $conexao->query(
    "SELECT SUM(valor_comissao) AS total FROM compras
     WHERE MONTH(data) = MONTH(NOW()) AND YEAR(data) = YEAR(NOW())"
)->fetch_assoc();

echo json_encode([
    "total_produzido" => intval($produzido["total"]),
    "total_vendido" => intval($vendido["total"]),
    "lucro_mes" => floatval($lucro["total"])
]);

$conexao->close();
