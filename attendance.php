<?php

date_default_timezone_set('America/Los_Angeles');

echo 'Loading Attendance Records';
echo "\n";

$data_path = 'data/attendancerecords.csv';
$summary_path = 'data/example_output.csv';

$file = fopen( $data_path, 'r' );
$totals = array();
do {
  $record = fgetcsv( $file );
  list( $student_id, $check_in, $check_out )  = $record;
  if ( ! $student_id || ! $check_in || ! $check_out )
    continue;

  $seconds = strtotime( $check_out ) - strtotime( $check_in );
  $records [ $student_id ][ date( "Y-m-d h:i:s", strtotime( $check_in ) ) ] = array(
    'added'  => $seconds,
    'result' => $totals[ $student_id ],
  );

  if ( $seconds <= 0 )
    continue;

  $raw_student_id[ $student_id ] = true;
  //$student_id = substr( $student_id, -4 );
  if ( ! array_key_exists( $student_id, $totals ) ) {
    $totals[ $student_id ] = $seconds;
  } else {
    $totals[ $student_id] += $seconds;
  }

} while ( !feof( $file ) );
fclose( $file );

foreach ( $totals as $id => $seconds ) {
  $totals[$id] = $seconds / ( 60 * 60 );
}

asort( $records );

if ( count( $totals) !== count( $raw_student_id) ){
    echo 'WARNING: Student ID collision. Must add more digits.';
}

$file = fopen( $summary_path,"w");

foreach ( $totals as $id => $hours )
{
  fputcsv( $file, array( $id, $hours ) );
}

fclose( $file );
