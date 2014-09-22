# Administrator Container for Radial Wheels

The image created with this Dockerfile is designed to be attached to an already
running Radial Wheel. Since the Hub container already is sharing the
configuration in '/config', any data in '/data', all log files in '/log', and
all the supervisor and application socketfiles in '/run', running this admin
container allows one quick access and control over all useful areas of a Wheel.
A user can use this image to manage supervisor processes via `supervisorctl` and
by specifying the desired socket located in '/run/supervisor' with the `-s`
option, or even log into a database via it's socket, also in '/run'.

If you use interactively, the list of Spokes attached to the hub are listed in
the `$SPOKES` variable, and upon startup, the path to each Spoke socket is made
available as a variable named `$appname_sock`.

Run interactively:

`docker run -it --rm --volumes-from myprogram_hub_1 --name myprogram_admin radial/admin bash`
> Note: you may also run this image non-interactively with any other "one-off" command appended to the end replacing `bash`.

Run as SSH host:

`docker run -d --rm --volumes-from myprogram_hub_1 --name myprogram_admin -e "GH_USER=githubusername" radial/admin`

Should you need access to the contents of the Hub container via SSH (in case any
of the Spokes doesn't have it themselves already), you may run detached and
assign `$GH_USER` with your Github username to insert your public keys into the
admin container thereby allowing you access and control over the Wheel via this
admin container as a proxy.
