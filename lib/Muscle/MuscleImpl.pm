package Muscle::MuscleImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

Muscle

=head1 DESCRIPTION

A KBase module: Muscle
This sample module contains one small method - filter_contigs.

=cut

#BEGIN_HEADER
use Bio::KBase::AuthToken;
use Bio::KBase::workspace::Client;
use Config::IniFiles;
use Data::Dumper;
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    
    my $config_file = $ENV{ KB_DEPLOYMENT_CONFIG };
    my $cfg = Config::IniFiles->new(-file=>$config_file);
    my $wsInstance = $cfg->val('Muscle','workspace-url');
    die "no workspace-url defined" unless $wsInstance;
    
    $self->{'workspace-url'} = $wsInstance;
    
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 filter_contigs

  $return = $obj->filter_contigs($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Muscle.FilterContigsParams
$return is a Muscle.FilterContigsResults
FilterContigsParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Muscle.workspace_name
	contigset_id has a value which is a Muscle.contigset_id
	min_length has a value which is an int
workspace_name is a string
contigset_id is a string
FilterContigsResults is a reference to a hash where the following keys are defined:
	new_contigset_ref has a value which is a Muscle.ws_contigset_id
	n_initial_contigs has a value which is an int
	n_contigs_removed has a value which is an int
	n_contigs_remaining has a value which is an int
ws_contigset_id is a string

</pre>

=end html

=begin text

$params is a Muscle.FilterContigsParams
$return is a Muscle.FilterContigsResults
FilterContigsParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Muscle.workspace_name
	contigset_id has a value which is a Muscle.contigset_id
	min_length has a value which is an int
workspace_name is a string
contigset_id is a string
FilterContigsResults is a reference to a hash where the following keys are defined:
	new_contigset_ref has a value which is a Muscle.ws_contigset_id
	n_initial_contigs has a value which is an int
	n_contigs_removed has a value which is an int
	n_contigs_remaining has a value which is an int
ws_contigset_id is a string


=end text



=item Description

Filter contigs in a ContigSet by DNA length

=back

=cut

sub run_muscle
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to run_muscle:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'run_muscle');
    }

    my $ctx = $Muscle::MuscleServer::CallContext;
    my($return);
    #BEGIN run_muscle
    
    print("Starting run muscle method.\n");
    
    if (!exists $params->{'workspace'}) {
        die "Parameter workspace is not set in input arguments";
    }
    my $workspace_name=$params->{'workspace'};
    
		if (!exists $params->{'feature_ids'}) {
        print  "Parameter feature_ids is not set in input arguments";
    }
    my $feature_ids=$params->{'feature_ids'};
    
    if (!exists $params->{'featureset_id'}) {
        print  "Parameter featureset_id is not set in input arguments";
    }
    my $featureset_id=$params->{'featureset_id'};

		if (!exists $params->{'feature_ids'} && !exists $params->{'featureset_id'}){
			die "Parameter feature_ids or featureset_id is required!!";
		}
    
    if (!exists $params->{'seq_type'}) {
        die "Parameter seq_type is not set in input arguments";
    }
    my $seq_type = $params->{'seq_type'};

    
    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Bio::KBase::workspace::Client->new($self->{'workspace-url'},token=>$token);
    my $featureSet=undef;
 
		print Dumper($params->{'feature_ids'});
		
		foreach my $feature_id ($params->{'feature_ids'}){

			print "$feature_id\n";
			my $feature=$wsClient->get_objects([{workspace=>$workspace_name,name=>$feature_id}])->[0]{data};
			print Dumper($feature). "\n\n";

		}	
	
=pod

		eval {
        $featureSet=$wsClient->get_objects([{workspace=>$workspace_name,name=>$featureset_id}])->[0]{data};
    };
    if ($@) {
        die "Error loading original FeatureSet object from workspace:\n".$@;
    }
    my $features=$featureSet->{features};

    print("Got FeatureSet data.\n");


		foreach my $feature_id (@{$params->{'featureset_ids'}}){
			print "$feature_id\n";
			my $feature=$wsClient->get_objects([{workspace=>$workspace_name,name=>$feature_id}])->[0]{data};

			print Dumper $feature."\n\n";
		
	
		}

=pod
    my $good_contigs=[];
    my $n_total = 0;
    my $n_remaining = 0;
    for my $contig (@$contigs) {
        $n_total++;
        if (length($contig->{'sequence'}) >= $min_length) {
            push(@$good_contigs, $contig);
            $n_remaining++;
        }
    }

    # replace the contigs in the contigSet object in local memory
    $contigSet->{'contigs'} = $good_contigs;
    
    print("Filtered ContigSet to ".$n_remaining." contigs out of ".$n_total."\n");

################## stopped here

    # save the new object to the workspace
    my $obj_info_list = undef;
    eval {
        $obj_info_list = $wsClient->save_objects({
            'workspace'=>$workspace_name,
            'objects'=>[{
                'type'=>'KBaseGenomes.ContigSet',
                'data'=>$contigSet,
                'name'=>$contigset_id,
                'provenance'=>$provenance
            }]
        });
    };
    if ($@) {
        die "Error saving filtered ContigSet object to workspace:\n".$@;
    }
    my $info = $obj_info_list->[0];


    print("saved:".Dumper($info)."\n");

    $return = {
        'new_contigset_ref'=>$info->[6].'/'.$info->[0].'/'.$info->[4],
        'n_initial_contigs'=>$n_total,
        'n_contigs_removed'=>$n_total-$n_remaining,
        'n_contigs_remaining'=>$n_remaining
    };
        
    print("returning: ".Dumper($return)."\n");
=cut   
 
    #END run_muscle
    my @_bad_returns;
    (ref($return) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"return\" (value was \"$return\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to filter_contigs:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'filter_contigs');
    }
    return($return);
}




=head2 version 

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}

=head1 TYPES



=head2 contigset_id

=over 4



=item Description

A string representing a ContigSet id.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 workspace_name

=over 4



=item Description

A string representing a workspace name.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 FilterContigsParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Muscle.workspace_name
contigset_id has a value which is a Muscle.contigset_id
min_length has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Muscle.workspace_name
contigset_id has a value which is a Muscle.contigset_id
min_length has a value which is an int


=end text

=back



=head2 ws_contigset_id

=over 4



=item Description

The workspace ID for a ContigSet data object.
@id ws KBaseGenomes.ContigSet


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 FilterContigsResults

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
new_contigset_ref has a value which is a Muscle.ws_contigset_id
n_initial_contigs has a value which is an int
n_contigs_removed has a value which is an int
n_contigs_remaining has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
new_contigset_ref has a value which is a Muscle.ws_contigset_id
n_initial_contigs has a value which is an int
n_contigs_removed has a value which is an int
n_contigs_remaining has a value which is an int


=end text

=back



=cut

1;
