package MetaBookMarks::GitPrompt;

# ABSTRACT: git porcelain command result parser.
use strict;
use warnings;

use Exporter qw(import);
 
our @EXPORT = qw(parseStatus);

sub parseStatus {
    my $line = shift;
    return {
        'branch' => "No commit",
        'icon' => " 🆕 "
    } if $line eq '## No commits yet on master';
    my $branch = '[\w\-]+(?:\.[\w\-]+)*';
    if($line =~ m!^##\s($branch)(?:\.\.\.($branch)/($branch)(?:\s(?:\[(?:(?:(ahead)\s(\d+))?(?:,\s)?(?:(behind)\s(\d+))?|(gone))?\])?)?)?!){
    #                  ]___1___[         ]__ 2 __[ ]__ 3 __[                ]_ 4 _[  ]_5_[             ]___6__[  ]_7_[   ]_ 8_[ 
      my $r = {'branch' => $1};
      my $opt = sub {$r->{$_[0]} = $_[1] if $_[1]};
      $opt->('remote', $2);
      $opt->('remoteBranch', $3);
      $opt->('is_ahead', $4);
      $opt->('n_ahead', $5);
      $opt->('is_behind', $6);
      $opt->('n_behind', $7);
      $opt->('gone', $8);
#      $opt->('icon'," 💚 ");
      $r
    }else{
      0
    }    
}

1;
