#!/usr/bin/perl
#Ce script a pour but de modifier les informations de versioning des fichiers apafis .xml.
#Si vous constatez un souci, merci de m'en faire part (petitd\@igbmc.fr)
#Benoit Petit-Demouliere, Phenomin-ICS
#V1.00 - 12/07/2021

use warnings;
use strict;
use Tk;
use Tk::FileSelect;
use Tk::LabEntry;
use Tk::DialogBox;
use Cwd;
use HTML::Entities;
use Encode qw(encode decode);

my $txt = "";
my $filename;
my $num;
my $version;
my $readonly;
my $name;

# initialisation de la fenetre principale
my $msg = MainWindow->new;
$msg->geometry("500x300+0+0");
$msg->title("Traitement des fichiers Apafis v1.00 Phenomin-ICS");

my $f = $msg->Frame(-borderwidth => 2, -relief => 'groove') ->pack(-side => 'left', -fill =>'both'); 
my $f2 = $msg->Frame(-borderwidth => 2, -relief => 'groove') ->pack(-side => 'bottom', -fill =>'x'); 


# message accueil
my $b_label = $msg->Message(
  -text    => "\n\n\nCe logiciel permet de retirer les informations de versions sur les fichier Apafis.\n\n\nAppuyez sur 'Fichier' pour choisir le fichier que vous souhaitez traiter\nou 'Quitter' pour sortir\n\nCredits: Benoit Petit-Demouliere - Phenomin-ICS",
  -width   => 450,
  -justify => 'center',
)->pack;

# boutons
my $b_fichier = $f->Button(
  -text    => "Fichier",
  -command => \&fichier
)->pack(-expand => 1);
my $b_clear = $f2->Button(
  -text    => "Retirer les informations",
  -state   => 'disabled',
  -command => \&traitement
)->pack(-side =>'bottom');
my $b_change = $f2->Button(
  -text    => "Editer les informations",
  -state   => 'disabled',
  -command => \&change
)->pack(-side =>'bottom');
my $b_quitter = $f->Button(
  -text    => "Quitter",
  -command => sub {exit;}
)->pack( -expand => 1);

# Affichage des informations du fichier
my $label_version = $msg->Label (
  -textvariable => \$version,
)->pack( ); 
my $label_num = $msg->Label (
  -textvariable => \$num,
)->pack( );  
my $label_readonly = $msg->Label (
  -textvariable => \$readonly,
)->pack( ); 
 
  
# Boucle principale
MainLoop;

#Action du bouton Fichier
sub fichier {
	#Initialisation des variables version, numero et lecture seule
	  $num="";
	  $version="";
	  $readonly=""; 

	#Liste desfichiers xml uniquement
	my $types = [ 
		  [ 'Fichiers xml', '.xml' ],
		  ['Tous les fichiers',    '*']
	  ];
	my $dir = ".";

	# fenetre de choix d un fichier
	  $filename = $msg->getOpenFile(
		-filetypes  => $types,
		-initialdir => "."
	  );
	if ( defined $filename and $filename ne '' ) {
	  $filename = encode( 'iso-8859-1', $filename );
	  $txt
		  = "\n\nVous avez choisi $filename\n\nAppuyez sur 'Retirer les informations'\nou 'Editer les informations' pour entrer de nouvelles valeurs\nou 'Fichier' pour changer de fichier.\nLe fichier original ne sera jamais modifie\n";

	#Ouverture du fichier choisi pour afficher les informations version, numero et lecture seule.

	open(FH, $filename) or die("File $filename not found");
	while(my $String = <FH>)
		{
			if($String =~ /<ReferenceDossier>/){
				$String =~ s/\<ReferenceDossier\>/Num. de dossier: /;
				$String =~ s/\<\/ReferenceDossier\>//;
				$version =  $String;
			}
			if($String =~ /<NumVersion>/){
				$String =~ s/\<NumVersion\>/Version: /;
				$String =~ s/\<\/NumVersion\>//;
				$num = $String;
			}
			if($String =~ /LectureSeule="true"/){
				$readonly = "Lecture Seule : OUI";
			}
		}
	close(FH);

		$b_label->configure( -text => $txt );
		$b_label->update;

		# on a choisi un fichier, on active le bouton continuer
		$b_clear->configure( -state => 'active' );
		$b_change->configure( -state => 'active' );
		$b_clear->update;
		$b_change->update;
		}
}

#Action du bouton Retirer les informations
sub traitement {
	#Creation du fichier edited qui contiendra les modifications
	open IN,$filename or die $!;
	$filename =~ s/.xml//;
	$filename = $filename."-edited.xml";
	open OUT,">",$filename or die $!;

	#Chaque ligne est lue, modifiee a la volee et ecrite dans e le fichier edited
	while (<IN>) {
	my $line = $_;
	if ($line =~ /LectureSeule="true"/){
	$line =~ s/LectureSeule=\"true\" //;
	print OUT $line;
	}
	print OUT $line unless /<NumVersion>|<ReferenceDossier>|LectureSeule="true"/;
	}

	close IN or die $!;
	close OUT or die $!;

	# traitement en cours, on desactive le bouton Fichier
	$b_fichier->configure( -state => 'disabled' );
	$b_clear->configure( -state => 'disabled' );
	$b_change->configure( -state => 'disabled' );
	$txt = "Traitement de $filename\n";

	$txt = "\n\nCorrection faite dans le fichier :\n\n$filename\n\nCliquer sur Fichier pour traiter un nouveau fichier ou Quitter.\n\n";
	$b_label->configure( -text => $txt );
	$b_label->update; 
	$num="";
	$version="";
	$readonly="";
	$b_fichier->configure( -state => 'normal' );
}

sub change {
	#initialisation des nouvelles variables
	my $newversion;
	my $newnumero;
	my $answer;
	$txt = "Traitement de $filename\n";
	#Boite de dialogue demandant les nouvelles informations
	my $db = $msg->DialogBox(-title => 'Entrer les nouvelles informations', -buttons => ['Valider', 'Annuler'], -default_button => 'Valider'); 
	$db->add('LabEntry', -textvariable => \$newversion, -width => 30, -label => 'Version', -labelPack => [-side => 'left'])->pack;
	$db->add('LabEntry', -textvariable => \$newnumero, -width => 30, -label => 'Numero', -labelPack => [-side => 'left'])->pack; 
	$answer = $db->Show( );

	#Edition du fichier edited avec les infortmations saisies
	if ($answer eq "Valider") { 
		open IN,$filename or die $!;
		$filename =~ s/.xml//;
		$filename = $filename."-edited.xml";
		open OUT,">",$filename or die $!;

		while (<IN>) {
		my $line = $_;
		if ($line =~ /<ReferenceDossier>/){
		$line =~ s/\<ReferenceDossier\>//;
		$line =~ s/\<\/ReferenceDossier\>//;
		print OUT "              <ReferenceDossier>".$newnumero."</ReferenceDossier>\n" 
		}
		if ($line =~ /<NumVersion>/){
		$txt = "\nVoici le numero de version actuel.\n";
		$line =~ s/\<NumVersion\>//;
		$line =~ s/\<\/NumVersion\>//;
		$txt = "     ".$line."\n";
		print OUT "              <NumVersion>".$newversion."</NumVersion>\n"
		}
		if ($line =~ /LectureSeule="true"/){
		$line =~ s/LectureSeule=\"true\" //;
		print OUT $line;
		}
		print OUT $line unless /<NumVersion>|<ReferenceDossier>|LectureSeule="true"/;}

		close IN or die $!;
		close OUT or die $!;
		$txt = "\n\nCorrection faite dans le fichier :\n\n$filename\n\nCliquer sur Fichier pour traiter un nouveau fichier ou Quitter.\n\n";
		}
	if ($answer eq "Annuler") {
		$txt = "\n\nAucune modification effectuee. Cliquer sur Fichier pour traiter un nouveau fichier ou Quitter.\n\n";
		}
	# traitement en cours, on desactive le bouton Fichier
	$b_fichier->configure( -state => 'disabled' );
	$b_clear->configure( -state => 'disabled' );
	$b_change->configure( -state => 'disabled' );

	$b_label->configure( -text => $txt );
	$b_label->update; 
	$b_fichier->configure( -state => 'normal' );
	$num="";
	$version="";
	$readonly="";
}