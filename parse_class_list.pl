#!/usr/bin/perl
use strict;
use warnings;

#
# convert file with
#  pdftotext -layout -nopgbrk class_list_KG_2013.pdf
#  and its 2 lines per child with most fields sorta aligned
#  Have to fix people with long international mobile #s manually
#
my $LIST = "class_list_KG_2013.txt";
my($class, $SFirst, $SLast, $rest, $line2);
my ($Addr1, $Addr2, $Homephone, $P1first, $P1last, $P1phone, $P1email, $P2first, $P2last, $P2phone, $P2email);

open(LIST, $LIST) or die "Cannot open $LIST for reading: $!\n";
while (<LIST>) {
    chomp;

    if ($_ =~ /Class KG/) {
        ($class) = ($_ =~ /Class KG (\w+)/);
        next;
    }
    next if ($_ =~ /^$|^Student|Note:|^contact among/);

    $SFirst = $SLast = $Addr1 = $P1first = $P1phone = $P1email = "";
    $Addr2 = $Homephone = $P2first = $P2phone = $P2email = "";

    # First Line
    if (/^[A-Z]/) {
        # watch out for those hyphens and apostrophes! Lets just say your name
        # is basically anything that is not white space :-)

        # not everyone on the first line has an email address...
        if ($_ =~ /\@/) {
            ($SFirst, $SLast, $Addr1, $P1first, $P1phone, $P1email) = ($_ =~ /(\S+) (\S+)\s+(.*?,)  \s+([\S\s]{1,}?)  \s+([0|\+][\d+ ]+\d+) ([ A-Za-z].*)/);
        }
        else {
            if ($_ =~ /(\S+) (\S+)\s+(.*?,)  \s+([\S\s]{1,}?)  \s+([0|\+][\d+ ]+\d+)/) {
                $SFirst = $1;
                $SLast = $2;
                $Addr1 = $3;
                $P1first = $4;
                $P1phone = $5;
                $P1email = "";
            }
            elsif ($_ =~ /(\S+) (\S+)\s+(.*?,)  \s+([\S\s]{1,})/) {
                $SFirst = $1;
                $SLast = $2;
                $Addr1 = $3;
                $P1first = $4;
                $P1first =~ s/ *$//;
                $P1phone = "";
                $P1email = "";
            }
            else {
                print "FAILED: $_\n";
            }
        }
        $Addr1 =~ s/,$//;
        print "($SFirst, $SLast, $Addr1, $P1first, $P1phone, $P1email)\n";

        # read in line 2
        $line2 = <LIST>;
        $rest="";
        if ($line2 =~ /\(02\)/) {
            ($Addr2, $Homephone, $rest) = ($line2 =~ /^\s+([\S\s]{1,}?\d+) \s+(\(02\) \d+\s*\d+)(.*)/);
        }
        else {
            ($Addr2, $rest) = ($line2 =~ /^\s+([\S\s]{1,}?\d+)(.*)/);
            $Homephone = "";
        }
        if ($rest ne "") {
            # not everyone on the second line has an email address...
            if ($rest =~ /\@/) {
                ($P2first, $P2phone, $P2email) = ($rest =~ /\s+([\S\s]{1,}?)  \s+([0|\+][\d+ ]+\d+) ([ A-Za-z].*)/);
            }
            else {
                ($P2first, $P2phone) = ($rest =~ /\s+([\S\s]{1,}?)  \s+([0|\+][\d+ ]+\d+)/);
                $P2email = "";
            }
        }
        print "[$Addr2, $Homephone, $P2first, $P2phone, $P2email]\n\n";

        #print "($SFirst, $SLast, $Addr1, $P1first, $P1phone, $P1email)\n";
        #print "[$Addr2, $Homephone, $P2first, $P2phone, $P2email]\n\n";

        if ($P1first ne "") {
        open(VCARD, "> Scots\ $class\ -\ $P1first\ ($SFirst).vcf") or die "Cannot open Scots $class - $P1first ($SFirst).vcf for writing: $!\n";
        print VCARD "BEGIN:VCARD\n";
        print VCARD "VERSION:3.0\n";
        print VCARD "FN:Scots $class - $P1first ($SFirst)\n";
        print VCARD "EMAIL;TYPE=INTERNET:$P1email\n";
        print VCARD "TEL;TYPE=CELL:$P1phone\n";
        print VCARD "TEL;TYPE=HOME:$Homephone\n";
        print VCARD "ADR;TYPE=HOME:;;$Addr1;$Addr2;;;\n";
        print VCARD "NOTE:This list is circulated on the clear understanding that details are for the sole purposes of facilitating contact among College families for organisation of transport and other arrangements concerning boys. Under no circumstances are lists to be used for political or commercial purposes, as this would be contrary to the purpose for which the lists have been created, and to the information given by parents to the College.\n";
        print VCARD "END:VCARD\n";
        close(VCARD);
        }

        if ($P2first ne "") {
        open(VCARD, "> Scots\ $class\ -\ $P2first\ ($SFirst).vcf") or die "Cannot open Scots $class - $P2first ($SFirst).vcf for writing: $!\n";
        print VCARD "BEGIN:VCARD\n";
        print VCARD "VERSION:3.0\n";
        print VCARD "FN:Scots $class - $P2first ($SFirst)\n";
        print VCARD "EMAIL;TYPE=INTERNET:$P2email\n";
        print VCARD "TEL;TYPE=CELL:$P2phone\n";
        print VCARD "TEL;TYPE=HOME:$Homephone\n";
        print VCARD "ADR;TYPE=HOME:;;$Addr1;$Addr2;;;\n";
        print VCARD "NOTE:This list is circulated on the clear understanding that details are for the sole purposes of facilitating contact among College families for organisation of transport and other arrangements concerning boys. Under no circumstances are lists to be used for political or commercial purposes, as this would be contrary to the purpose for which the lists have been created, and to the information given by parents to the College.\n";
        print VCARD "END:VCARD\n";
        close(VCARD);
        }
    }

}
close(LIST);

