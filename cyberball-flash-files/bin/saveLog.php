<?php
$userId = $_POST['userId'];
$ts = date('Ymd His');
$handle = fopen('logs/'.$userId.'_'.$ts.'.csv',"w+");
fwrite($handle,$_POST['log']);
fclose($handle);
?>