package MetaBookMarks::GitPrompt;

# ABSTRACT: git porcelain command result parser.
use strict;
use warnings;

use Try::Tiny;

use MetaBookMarks::Git;


use Exporter qw(import);
 
our @EXPORT = qw(parseStatusLine parseFilesStatus gitPrompt);

our ($warning, $cool, $reset,$debug);

sub gitPrompt {
  ($warning, $cool, $reset,$debug) = @_;

  my $repo = MetaBookMarks::Git->repository() 
   || exit(0);

  my $cmd = $repo->openCommand('status', '-b', '--porcelain');
  
  my $head = $cmd->readLine();
  
  print(parseFilesStatus($cmd));
  
  print $warning, '±', $cool, '±', $reset;

  printStatusLine(parseStatusLine($head));
    
}


sub printStatusLine {
  my ($branch, $remote, $remoteBranch,$is_ahead,$n_ahead,$is_behind, $n_behind, $gone) = @_;

  my @remote=();
  
  push @remote, "$n_ahead⬆️" if $is_ahead;
  push @remote, "$n_behind⬇️" if $is_behind;
  print ' - ', join(' 🔥', @remote) if @remote;
    
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



sub parseFilesStatus {
  my $cmd = shift;
  my $git = $cmd->{fh};
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
  push @states, ' - ' if @states;
  @states
}

sub dump {
    print "\n";
    while (my ($i, $e) = each @_) {
     warn $i+1, " -> $e\n";
   }
}

1;

################ Documentation ################

=head1 NAME

MetaBookMarks::GitPrompt - provide fancy git prompt.

=head1 SYNOPSIS

use Getopt::Long;

use MetaBookMarks::GitPrompt;

my $warning;
my $cool;
my $reset;
my $debug=0;
GetOptions ("warning=s" => \$warning,   # String
            "cool=s"    => \$cool,      # string
            "reset=s"    => \$reset,    # string
            "debug=i"   => \$debug)     # Numeric
or die("Error in command line arguments\n");


my $prompt = gitPrompt($warning, $cool, $reset, $debug);

=head1 DESCRIPTION

To use with ZSH them by instance.

=head2 gitPrompt

Output the prompt

Parameters: warn color, green cool, reset color, debug level.

=head2 parseStatusLine

Parses the first line result of git status -b --porcelain 


=head2 parseFilesStatus

Parses the individial status of files in the repository, it returns 
an array of emoij reflecting the state of files

New, conflict etc ...

