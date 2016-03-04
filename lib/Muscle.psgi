use Muscle::MuscleImpl;

use Muscle::MuscleServer;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = Muscle::MuscleImpl->new;
    push(@dispatch, 'Muscle' => $obj);
}


my $server = Muscle::MuscleServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
