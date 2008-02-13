###############################################################################
## OCSINVENTORY-NG 
## Copyleft Pascal DANEK 2008
## Web : http://ocsinventory.sourceforge.net
##
## This code is open source and may be copied and modified as long as the source
## code is always made freely available.
## Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt
################################################################################
package Apache::Ocsinventory::Interface::History;

use Apache::Ocsinventory::Interface::Database;
use XML::Simple;

use strict;

require Exporter;

our @ISA = qw /Exporter/;

our @EXPORT = qw / 
  get_history_events
  clear_history_events
/;

sub get_history_events {
  my( $begin, $num ) = @_;
  my @tmp;
  my $sth = get_sth( "SELECT DATE,DELETED,EQUIVALENT FROM deleted_equiv ORDER BY DATE LIMIT $begin,$num" );
    
  while( my $row = $sth->fetchrow_hashref() ){
    push @tmp, {
        'DELETED' => [ $row->{'DELETED'} ],
        'DATE' => [ $row->{'DATE'} ],
        'EQUIVALENT' => [ $row->{'EQUIVALENT'} ]
    }
  }
  $sth->finish();
  return XML::Simple::XMLout( {'EVENT' => \@tmp} , RootName => 'EVENTS' );
}

sub clear_history_events {
  my( $begin, $num ) = @_;
  my $sth = get_sth( "SELECT * FROM deleted_equiv ORDER BY DATE LIMIT $begin,$num" );
  while( my $row = $sth->fetchrow_hashref() ) {
    do_sql('DELETE FROM deleted_equiv WHERE DELETED=? AND DATE=? AND EQUIVALENT=?', $row->{'DELETED'}, $row->{'DATE'}, $row->{'EQUIVALENT'}) or die;
  }
  return 1;
}
