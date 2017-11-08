#!/usr/bin/perl
#
# written by Ray Ball WFO MOB
# modified by rg CYS 5 Jun 2017

use Image::Magick;
use Time::Local;

$postToFacebook = "N";
$workingDir = "/localapps/runtime/GFE";
$triggerDir = "/awips2/edex/data/fxa/trigger";
$timeStamp = `/bin/date "+%Y%m%d%H%M%S"`;
chomp ($timeStamp);
`/bin/cp $triggerDir/CYSWRKGRF $workingDir/data/CYSWRKGRF_$timeStamp`;

#@ccfSites = ("CYS,915,973","LAR,622,920","RWL,219,735","DGW,649,387","TOR,973,692","BFF,1159,767","CDR,1328,459","SNY,1375,952","SAR,353,952","AIA,1350,656","LSK,985,410");
@ccfSites = ("CYS,915,973","LAR,622,920","RWL,219,735","DGW,649,387","TOR,973,692","BFF,1159,767","CDR,1328,459","SNY,1375,952","SAR,353,952","AIA,1350,656","LSK,985,410","EAN,735,686","BGS,96,970");
%forecastList = (
	U=>'SUNNY2',
	V=>'CLEAR2',
	A=>'FAIR2',
	B=>'PTCLDY2',
	E=>'MOCLDY2',
	C=>'CLOUDY2',
	G=>'VRYHOT2',
	I=>'VRYCLD2',
	F=>'FOGGY2',
	H=>'HAZE2',
	K=>'SMOKE2',
	D=>'DUST2',
	N=>'WINDY2',
	L=>'DRZL2',
	R=>'RAIN2',
	O=>'RNSNOW2',
	S=>'SNOW2',
	J=>'SNOSHWR2',
	M=>'FLRRYS2',
	P=>'BLZZRD2',
	Q=>'BLGSNO2',
	W=>'SHWRS2',
	T=>'TSTRMS2',
	X=>'SLEET2',
	Y=>'FZRAIN2',
	Z=>'FZDRZL2'
);
				
%popCodes = (
	'0'=>'0',
	'-'=>'0',
	'1'=>'10',
	'2'=>'20',
	'3'=>'30',
	'4'=>'40',
	'5'=>'50',
	'6'=>'60',
	'7'=>'70',
	'8'=>'80',
	'9'=>'90',
	'+'=>'100',
	'/'=>'Missing'
);

%weekDays = (
	'0'=>'sunday',
	'1'=>'monday',
	'2'=>'tuesday',
	'3'=>'wednesday',
	'4'=>'thursday',
	'5'=>'friday',
	'6'=>'saturday'
);

%monthNumbers = (
	JAN=>'1',
	FEB=>'2',
	MAR=>'3',
	APR=>'4',
	MAY=>'5',
	JUN=>'6',
	JUL=>'7',
	AUG=>'8',
	SEP=>'9',
	OCT=>'10',
	NOV=>'11',
	DEC=>'12',
);

%graphicastNUM = (
	first=>21,
	second=>22,
	third=>23
);                

open (CCFIN,"<$triggerDir/CYSWRKGRF") or die "Could not open CCF file for reading";
@ccf = <CCFIN>;
close CCFIN;
$ccf = join (" ",@ccf);
if ($ccf eq "") {
	die "CCF file has no content\n";
}
@periods = qw(first second third);

foreach $period (@periods) {
	${$period."PeriodImage"}=Image::Magick->new;
	${$period."PeriodImage"}->Read("$workingDir/images/image_generator_map.jpg");
}
($ccfX,$ccfY) = $firstPeriodImage->Get('width','height');

if ($ccf =~/(\w\w\w) (\d\d) (\d\d) (\d\d):(\d\d):(\d\d) GMT/) {
	$startMonth = $monthNumbers{$1};
	$startDay = sprintf("%d",$2);
	$startYear = "20".$3;
	$startHour = sprintf("%d",$4);
	$startMinute = sprintf("%d",$5);
	$startSecond = sprintf("%d",$6);
}

foreach $siteInfo (@ccfSites) {
	$firstPeriodForecast = "";
	$secondPeriodForecast = "";
	$thirdPeriodForecast = "";
	$firstPeriodTemp = "";
	$secondPeriodTemp = "";
	$thirdPeriodTemp = "";
	$firstPeriodPOP = "";
	$secondPeriodPOP = "";
	$thirdPeriodPOP = "";
	($site,$x,$y) = split(/,/,$siteInfo);
	if ($ccf =~ /$site ([\w\?]{1})([\w\?]{1})([\w\?]{1})[\w\?]{2} ([\dM]{3})\/([\dM]{3}) ([\dM]{3})\/[\dM]{3} [\dM]{3} \d\d([0-9-\+\/]{1})([0-9-\+\/]{1})([0-9-\+\/]{1})\n\s+[\w\?]{8} [\dM]{3}\/[\dM]{3} [\dM]{3}\/[\dM]{3} [\dM]{3}\/[\dM]{3} [\dM]{3}\/[\dM]{3} [0-9-\+\/]{10}\n/) {
		$firstPeriod = "today";
		$firstPeriodTime = "DAY";
		$secondPeriod = "tonight";
		$secondPeriodTime = "NIGHT";
		$thirdPeriod = "tomorrow"; 
		$thirdPeriodTime = "DAY";
		$firstPeriodForecast = $1;
		$secondPeriodForecast = $2;
		$thirdPeriodForecast = $3;
		$firstPeriodTemp = $4;
		$secondPeriodTemp = $5;
		$thirdPeriodTemp = $6;
		$firstPeriodPOP = $7;
		$secondPeriodPOP = $8;
		$thirdPeriodPOP = $9;
#		print "$site  $firstPeriodTime  $forecastList{$firstPeriodForecast} $firstPeriodTemp $popCodes{$firstPeriodPOP}%  $forecastList{$secondPeriodForecast} $secondPeriodTemp $popCodes{$secondPeriodPOP}%  $forecastList{$thirdPeriodForecast} $thirdPeriodTemp $popCodes{$thirdPeriodPOP}%\n";
	}
	elsif ($ccf =~ /$site ([\w\?]{1})([\w\?]{1})([\w\?]{1})[\w\?]{2} ([\dM]{3})\/([\dM]{3}) ([\dM]{3})\/[\dM]{3} [\dM]{3} \d\d([0-9-\+\/]{1})([0-9-\+\/]{1})([0-9-\+\/]{1})\n\s+[\w\?]{9} [\dM]{3}\/[\dM]{3} [\dM]{3}\/[\dM]{3} [\dM]{3}\/[\dM]{3} [\dM]{3}\/[\dM]{3} [\dM]{3} [0-9-\+\/]{11}\n/) {
		$firstPeriod = "tonight";
		$firstPeriodTime = "NIGHT";
	#	$secondPeriod = "today";
                $secondPeriod = "tomorrow";
		$secondPeriodTime = "DAY";
		$thirdPeriod = "tomorrownight";
		$thirdPeriodTime = "NIGHT";
		$firstPeriodForecast = $1;
		$secondPeriodForecast = $2;
		$thirdPeriodForecast = $3;
		$firstPeriodTemp = $4;
		$secondPeriodTemp = $5;
		$thirdPeriodTemp = $6;
		$firstPeriodPOP = $7;
		$secondPeriodPOP = $8;
		$thirdPeriodPOP = $9;
#		print "$site  $firstPeriodTime  $forecastList{$firstPeriodForecast} $firstPeriodTemp $popCodes{$firstPeriodPOP}%  $forecastList{$secondPeriodForecast} $secondPeriodTemp $popCodes{$secondPeriodPOP}%  $forecastList{$thirdPeriodForecast} $thirdPeriodTemp $popCodes{$thirdPeriodPOP}%\n";
	}
	else {
		print "$site does not exist.\n";
	}
	foreach $period (@periods) {
		if ((${$period.'PeriodTime'} eq "DAY") or (${$period.'PeriodTime'} eq "NIGHT")) {
			${$period."PeriodTemp"} =~ s/^9/-/;
			${"formatted".$period."PeriodTemp"} = sprintf("%d",${$period."PeriodTemp"});
		       if(${$period.'Period'} eq "tonight"){
                          ${$period."PeriodImage"}->Annotate (
			  	  text=>${"formatted".$period."PeriodTemp"},
			  	  font=>'/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf',
				  #style=>'bold',
				  stroke=>'black',
				  strokewidth=>3,
				  fill=>'turquoise1',
				  pointsize=>'50',
				  x=>$x+15, y=>$y-20
			);
                        }
                        else{
                          ${$period."PeriodImage"}->Annotate (
			 	  text=>${"formatted".$period."PeriodTemp"},
				  font=>'/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf',
				  #style=>'bold',
				  stroke=>'black',
				  strokewidth=>3,
				  fill=>'yellow',
				  pointsize=>'50',
				  x=>$x+15, y=>$y-20
			);
                        }
			$forecastFileName = "$forecastList{${$period.'PeriodForecast'}}_${$period.'PeriodTime'}.png";
			if (not(-e "$workingDir/icons/$forecastFileName")) {
				$forecastFileName = "$forecastList{${$period.'PeriodForecast'}}.png";
			}
			if (not(-e "$workingDir/icons/$forecastFileName")) {
				die "$forecastFileName does not exist";
			}	
			if (${$period."PeriodForecast"} =~ /\w/) {
				$forecastIcon=Image::Magick->new;
				$forecastIcon -> Read("$workingDir/icons/$forecastFileName");
				($iconX,$iconY) = $forecastIcon->Get('width','height');
				${$period."PeriodImage"}->Composite (
					image=>$forecastIcon,
					compose=>'over',
					x=>($x-$iconX)+10,y=>($y-$iconY)+15
				);
			}
			if (${$period."PeriodPOP"} =~ /[0-9-\+\/]{1}/) {
				${$period."PeriodImage"}->Annotate (
					text=>"$popCodes{${$period.'PeriodPOP'}}%",
					font=>'/usr/share/fonts/dejavu/DejaVuSans-BoldOblique.ttf',
					style=>'italic',
					stroke=>'black',
					strokewidth=>2,
					fill=>'green2',
					pointsize=>'38',
					x=>$x+15, y=>$y+10
				        
				);
			}
                #Create Time Stamp
                &CheckDST;
	        if ($DST > 0) {
		$Offset = 21600;
                $stamp = MDT;
	         }
	        else {
		$Offset = 25200;
                $stamp = MST;
	        }
                $time = time() - $Offset;
                ($sec,$min,$hour,$day,$month,$year) = (gmtime($time))[0,1,2,3,4,5];
                $year = $year + 1900;
                $month = $month + 1; #have to add +1 due to the script starting at 0
                if($min < 10){$min = "0$min";}
                
                ${$period."PeriodImage"}->Annotate (
                font=>'/usr/share/fonts/dejavu/DejaVuSans-BoldOblique.ttf',
                pointsize=>'20',
                fill=>'white',
                stroke=>'black',
                text=>"Created: $month/$day/$year $hour:$min $stamp",
		x=>10, y=>1100
                
                        );
		}
	}
 }
&GetDayofWeek($firstPeriodTime,$startMonth,$startDay,$startYear,$startHour,$startMinute,$startSecond);

foreach $period (@periods) {
	$imageStamp=Image::Magick->new;
	$imageStamp->Read("$workingDir/images/".${$period.'Period2'}.".png"); #Use .Period2 to get the specific day
	($stampX,$stampY) = $imageStamp->Get('width','height');
	${$period."PeriodImage"}->Composite (
		image=>$imageStamp,
		compose=>'over',
		x=>10,y=>10
	);
	$ccfImageFilename = ${$period.'Period'}.".png";
	$ldadImageFilename = ${$period.'Period'}.".png"; #Use .Period to get "Today" & "Tonight" in order to send the images to the Web
	$ccfTextFilename = ${$period.'Period'}.".txt";
	if (($ccfTextFilename =~ /night/) and (not($ccfTextFilename =~ /tonight/))) {
		$descriptionName = $ccfTextFilename;
		$descriptionName =~ s/night\.txt//;
		$descriptionName = "$descriptionName Night";
		$descriptionName =~ s/\b([a-z])(\w+)\b/\u$1$2/g;
	}
	else {
		$descriptionName = $ccfTextFilename;
		$descriptionName =~ s/\.txt//;
		$descriptionName =~ s/\b([a-z])(\w+)\b/\u$1$2/g;
	}
	$imageLabel = $descriptionName."\'s Forecast";
	${$period."PeriodImage"}->Write (filename=>"$workingDir/data/$ccfImageFilename");
#	`scp $workingDir/data/$ccfImageFilename ldad\@ls1:/data/ldad/Lsync/$ldadImageFilename`;
	open (FILEOUT,">$workingDir/data/$ccfTextFilename") or die "Could not open description file for writing";
	print FILEOUT "Weather, temperature, and precipitation forecast for $descriptionName";
	close FILEOUT;
	undef $imageStamp;
	undef $shadowStamp;
	undef ${$period."PeriodImage"};
#	&PostToWeb($ccfTextFilename,$ccfImageFilename,$graphicastNUM{$period},$imageLabel);
}

undef $forecastIcon;

exit;

sub GetDayofWeek {
	&CheckDST;
	if ($DST > 0) {
		$gmtOffset = 21600;
	}
	else {
		$gmtOffset = 25200;
	}
	$startEpochTime = timegm($startSecond,$startMinute,$startHour,$startDay,$startMonth-1,$startYear);
	$localStartEpochTime = $startEpochTime - $gmtOffset;
	($sec,$min,$hr,$mday,$mon,$yr,$weekDay,$yday,$isdst) = localtime($localStartEpochTime);
  
	if ($weekDay > 5) {
		$nextWeekDay = 0;
	}
	else {
		$nextWeekDay = $weekDay + 1;
	}
        if ($weekDay eq 0){
                $previousWeekDay = 6;
        }
        else{
                $previousWeekDay = $weekDay - 1;
        }
	if ($firstPeriodTime eq "DAY") {
	#	$firstPeriod = "today";
	#	$secondPeriod = "tonight";
                $firstPeriod2 = $weekDays{$weekDay}; #the .Period2 is used to not overwrite the .Period used earlier for the output files
                $secondPeriod2 = $weekDays{$weekDay}."night";  
		$thirdPeriod = $weekDays{$nextWeekDay}; #Creates the output file with the name of the weekday.
	}
        elsif ($hour >= 0 && $hour < 3){ #this is to account for the midnight to 3am period. Still night but the next day.
                $firstPeriod2 = $weekDays{$previousWeekDay}."night";
		$secondPeriod2 = $weekDays{$weekDay};
		$thirdPeriod = $weekDays{$weekDay}."night";  #Creates the output file with the name of the weekday.
        }
	elsif ($firstPeriodTime eq "NIGHT") {
	#	$firstPeriod2 = "tonight";
                $firstPeriod2 = $weekDays{$weekDay}."night";
        #        $secondPeriod2 = "tomorrow";
		$secondPeriod2 = $weekDays{$nextWeekDay};
		$thirdPeriod = $weekDays{$nextWeekDay}."night";  #Creates the output file with the name of the weekday.
	}
	#print "$firstPeriod2 $secondPeriod2 $thirdPeriod2\n";
	return($firstPeriod2,$secondPeriod2,$thirdPeriod2);
}

sub CheckDST {
	($sec,$min,$hr,$mday,$mon,$yr,$weekDay,$yday,$isdst) = localtime();
	$currentEpochTime = time();
	$isDST = timegm(0,0,8,11,2,$yr);
	$notDST = timegm(0,0,8,4,10,$yr);
	if (($currentEpochTime ge $isDST) and ($currentEpochTime le $notDST)) {
		$DST = 1;
	}
	else {
		$DST = 0;
	}

	return($DST);
}

sub PostToWeb {
#	if (-e "$workingDir/config/autoPublishStatus.dat") {
#		open (STATUSIN,"<$workingDir/config/autoPublishStatus.dat") or die "Could not open status file for reading";
#		$autoPublishStatus = <STATUSIN>;
#		close STATUSIN;
#	}
#	else {
#		$autoPublishStatus = "ON";
#	}
#	if ($autoPublishStatus eq "ON") {
		$webCmd = "/localapps/runtime/send2web/bin/auto_publish.tcl --label=\"@_[3]\" --imagefile=$workingDir/data/@_[1] --textfile=$workingDir/data/@_[0] --expire=12 --tabplacement=@_[2] --subpageonly=N";
#		print "$webCmd\n";
#		system ($webCmd);
#	}
#	else {
#		next;
#	}
	$webCmd = "/localapps/runtime/GFE/sendfiles.sh";
	system ($webCmd);
}
