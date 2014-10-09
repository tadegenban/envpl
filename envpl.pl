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

=pod

=head1 NAME

    envpl -- set my current perl env for windows
=head2 DESCRIPTION

    envpl is a command to set the PATH and PERL5LIB Enviroment varible for you .

    Run 'envpl' in will add current directory's './bin' to PATH and './lib' to PERL5LIB at first place

    If current directory's './bin' and './lib' already at PATH's and PERL5LIB's first place,

    It will remove them for you .

    So, you can use 'envpl' to switch bewteen two enviroment status for devloping

=cut