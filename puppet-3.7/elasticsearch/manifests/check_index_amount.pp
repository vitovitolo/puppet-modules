define elasticsearch::check_index_amount
(
    $index_name = $name,
    $threshold = hiera("elasticsearch::check_index_amount::${name}::threshold", "40"),
)
{
    include elasticsearch
}
