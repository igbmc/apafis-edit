#!/usr/bin/perl

use Cwd;
use HTML::Entities;


print "
##########################
#                        #
# Apafis Versioning Tool #
#                        #
##########################\n
Ce script a pour but de modifier les informations de \nversioning des fichiers apafis .xml.
Si vous constatez un souci, merci de m'en faire part (petitd\@igbmc.fr)\n
Merci de faire votre choix :\n
Pour retirer les informations de versioning des \nfichiers xml de ce repertoire : Taper 1 puis Entree\n\n
Pour modifier les informations de versionings des \nfichiers, taper 2 puis Entree\n
Les fichiers seront crees avec la mention \"edited\"\n
Quittez en tapant Entree.\n\n\n";
chomp (my $result = <STDIN>);
if ($result == 1){
my $dir = ".";

opendir (DIR, "./") or die "cannot open dir $dir: $!";
my @files = glob "$dir/*.xml";
closedir(DIR);

foreach(@files){
  my $xmlfiles = $_;

print "\n\nVoulez-vous traiter le fichier :\n".$xmlfiles." ?\n";
print "1)  oui\n";
print "2)  non\n";
chomp (my $file = <STDIN>);
if ($file == 1){
open IN,$xmlfiles or die $!;
$xmlfiles =~ s/.xml//;
$xmlfiles = $xmlfiles."-edited.xml";
open OUT,">",$xmlfiles or die $!;


while (<IN>) {
my $line = $_;
if ($line =~ /LectureSeule="true"/){
print "\nCe dossier est en lecture seule.\nRetrait de cette limitation.\n";
$line =~ s/LectureSeule=\"true\" //;
print OUT $line;
}
print OUT $line unless /<NumVersion>|<ReferenceDossier>|LectureSeule="true"/;
}

close IN or die $!;
close OUT or die $!;
}
}
print "\n\nConversion finie ou aucun fichier xml dans le repertoire\nValidez pour fermer ce script.\nScript Version 1.1 - 09/07/2021.\n\n";
<STDIN>
}
if ($result == 2){
my $dir = cwd();

opendir DIR, $dir or die "cannot open dir $dir: $!";
my @files = glob "$dir/*.xml";
closedir(DIR);

foreach(@files){
  my $xmlfiles = $_;
print "\n\nVoulez-vous traiter le fichier :\n".$xmlfiles." ?\n";
print "1)  oui\n";
print "2)  non\n";
chomp (my $file = <STDIN>);
if ($file == 1){
open IN,$xmlfiles or die $!;
$xmlfiles =~ s/.xml//;
$xmlfiles = $xmlfiles."-edited.xml";
open OUT,">",$xmlfiles or die $!;


while (<IN>) {
my $line = $_;
if ($line =~ /<ReferenceDossier>/){
print "\nVoici le numero de dossier actuel.\n";
$line =~ s/\<ReferenceDossier\>//;
$line =~ s/\<\/ReferenceDossier\>//;
print "     ".$line."\n";
print "Entrer le nouveau numero de dossier.\n";
chomp (my $numdossier = <STDIN>);
print OUT "              <ReferenceDossier>".$numdossier."</ReferenceDossier>\n"
}
elsif ($line =~ /<NumVersion>/){
print "\nVoici le numero de version actuel.\n";
$line =~ s/\<NumVersion\>//;
$line =~ s/\<\/NumVersion\>//;
print "     ".$line."\n";
print "Entrer le nouveau numero de version.\n";
chomp (my $numversion = <STDIN>);
print OUT "              <NumVersion>".$numversion."</NumVersion>\n"
}
if ($line =~ /LectureSeule="true"/){
print "\nCe dossier est en lecture seule.\nRetrait de cette limitation.\n";
$line =~ s/LectureSeule=\"true\" //;
print OUT $line;
}
else {
print OUT $line unless /<NumVersion>|<ReferenceDossier>|LectureSeule="true"/;}
}
close IN or die $!;
close OUT or die $!;
}
}
print "\nConversion finie\nValidez pour fermer ce script.\nScript Version 1.1 - 09/07/2021.\n";
<STDIN>}

else{exit;}