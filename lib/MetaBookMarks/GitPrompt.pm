package MetaBookMarks::GitPrompt;

# ABSTRACT: git porcelain command result parser.
use strict;
use warnings;

use Git;

use Exporter qw(import);
 
our @EXPORT = qw(parseStatusLine parseFilesStatus gitPrompt);

our ($warning, $cool, $reset,$debug);

sub gitPrompt {
  ($warning, $cool, $reset,$debug) = @_;

  my $repo = Git->repository;
  my ($git, $ctx) = $repo->command_output_pipe('status', '-b', '--porcelain');

  
  my $head = <$git>;
  print(parseFilesStatus($git));
  
  print $warning, ' ±', $cool, '±', $reset;

  printStatusLine(parseStatusLine($head));
  
  $repo->command_close_pipe($git, $ctx);

  
}


sub printStatusLine {
  my ($branch, $remote, $remoteBranch,$is_ahead,$n_ahead,$is_behind, $n_behind, $gone) = @_;

  my @remote=();
  
  push @remote, "⬆️ -$n_ahead" if $is_ahead;
  push @remote, "⬇️ -$n_behind" if $is_behind;
  print '-{', join(', ', @remote), "}- " if @remote;
    
  my @branch=();

  if($gone){
    push @branch, "🔥 ", &warning($branch), "🔥"
  }elsif($remote){
    push @branch, $branch unless $branch eq "master";
    push @branch, warning($remote),'/', unless $remote eq "origin";
    push @branch, warning($remoteBranch) unless $branch eq $remoteBranch;
  } elsif($branch eq "HEAD") {
    push @branch, "👽 ", warning($branch), " ☠️"
  } else {
    push @branch, "🎉 ", warning($branch)
  }
  print '-]', @branch, '[-' if @branch;

}

sub warning {
   $warning, @_, $reset;
}

sub parseStatusLine {
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
      $opt->('remote_branch', $3);
      $opt->('is_ahead', $4);
      $opt->('n_ahead', $5);
      $opt->('is_behind', $6);
      $opt->('n_behind', $7);
      $opt->('gone', $8);
#      $opt->('icon'," 💚 ");
      return wantarray? ($1,$2,$3,$4,$5,$6,$7,$8): $r;
    }else{
      0
    }    
}

sub parseFilesStatus {
  my $git = shift;
  my @checks = (
    sub {$_[0] =~ /^[AMRD]/ && "🚀"},       #STAGED 
    sub {$_[0] =~/^.[MTD]/ && "🚧"},        #UNSTAGED
    sub {$_[0] =~/^\?\?/ && "👀"},          #UNTRACKED
    sub {$_[0] =~/^UU\s/ && "💥"},          # UNMERGED
    sub {$_[0] =~ /^## .*diverged/ && "😨"} # DIVERGED
  );
  my @states = ();
  while(<$git>){
    return @states unless @checks;
    for (my $i=@checks-1; $i >= 0; $i--){
      if(my $state = $checks[$i]->($_)){
            splice @checks, $i, 1;
            push @states, $state;
            last;
        }
    }
  }
  @states
}

sub dump {
    print "\n";
    while (my ($i, $e) = each @_) {
     warn $i+1, " -> $e\n";
   }
}


1;
