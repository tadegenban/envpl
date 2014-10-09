@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!perl
#line 15
use File::Spec::Functions qw( rel2abs catfile );
use List::MoreUtils qw( any );
use Win32::API;
use Win32::TieRegistry;
use constant HWND_BROADCAST => -1;
use constant WM_SETTINGCHANGE => 0x1a;

my $ENV = $Registry->{"CUser\\Environment"} or
    die "Can't read CUser/Enviroment key: $^E\n";
my $path = $ENV->{PATH};
my $perl5lib = $ENV->{PERL5LIB};

my $lib = rel2abs('./lib');
my $bin = rel2abs('./bin');

my @paths = split(/;/, $path);
my @perl5libs = split(/;/, $perl5lib);

if ( $paths[0] eq $bin ) {
    shift @paths;
    $ENV->{PATH} = join(';', @paths);
    print "- $bin from PATH \n";
}
else {
    $ENV->{PATH} = $bin .';' . $ENV->{PATH};
    print "+ $bin to PATH \n";
}

if ( $perl5libs[0] eq $lib ) {
    shift @perl5libs;
    $ENV->{PERL5LIB} = join(';', @perl5libs);
    print "- $lib from PERL5LIB \n";
}
else {
    $ENV->{PERL5LIB} = $lib .';' . $ENV->{PERL5LIB};
    print "+ $lib to PERL5LIB \n";
}

my $SendMessage = new Win32::API("user32", "SendMessage", 'NNNP', 'N') or
    die "Cound't create SendMessage: $!\n";
my $RetVal = $SendMessage->Call(HWND_BROADCAST, WM_SETTINGCHANGE,0,'Enviroment');



__END__
:endofperl
