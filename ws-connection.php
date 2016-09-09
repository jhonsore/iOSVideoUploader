<?php

$target_path = "uploads/";
//$target_path = $target_path . basename( $_FILES['file']['name']);  

if(move_uploaded_file($_FILES['file']['tmp_name'], $target_path.md5(time()).'.mp4')) {
    $status = "true";
} else {
    $status = "false";
}

$data = '{
	"status":"'.$status.'"
		
}';

echo $data;

?>