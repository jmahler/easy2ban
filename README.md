
NAME
----

easy2ban - Monitor logs and ban hosts.

DESCRIPTION
-----------

This system monitors logs for malicious activity and then
bans any host that matches the patterns.

There are two main daemons in this system: the easy2ban-rule daemon
and the easy2ban-ipban daemon.  And they communicate with each
other using directory of ban files representing banned IPs.

The easy2ban-rule daemon is the core program.  But it is configured
for different logs and patterns.  There can be more than
one of these running at the same time.  And they can all share
the same directory of ban files.

As an example, the following would monitor a local.log file for
the patters XXX or FAIL.

    $ ./easy2ban-rule -v -c "tail -qf local.log |" -L "qr/XXX/, qr/FAIL/"

And these patterns can be generated by simply echo'ing them to the file.

    $ echo "192.168.3.4 XXX" >> local.log
    $ echo "192.168.3.4 XXX" >> local.log
    $ echo "192.168.3.4 XXX" >> local.log

If enough of these patterns appear in the log at a fast enough rate the
easy2ban-rule daemon will ban the IP by writing a ban file.

There are numerous options that are not shown in this example.
They can be seen by viewing the help info (-h) or by looking at
the various examples which are included.

    easy2ban-local
    easy2ban-apache_error
    easy2ban-qmail_maillog
    easy2ban-qmail_imap4-ssl
    easy2ban-ssh

The arguments to easy2ban-rule may look a bit strange but this is because it
is written in Perl and these arguments accommodate this language.
The command (-c), "tail -qf local.log |", will be opened using the standard
Perl 'open' function.  And with the trailing pipe symbol the output of
this program will be pipe to this daemon.  In fact, any program or file
can be used for this argument.  The pattern (-L) option will be evaluated
in to a list of pre-compiled regexs.  Browse the source if any of this
is confusing, it is quite short.

    my @patterns = (eval('qr/XXX/, qr/FAIL/'));

So when easy2ban-rule bans a host it will write its IP to a ban file.
An example directory hierarchy might look like the following.
Notice that the file name itself is simply the IP address of the
banned host.

    var/ban$ ls
    192.168.2.3
    192.168.15.3

Each file contains a single integer value, the number of minutes
left since the host was banned.  Here we see that the first host
has three minutes left and the second has one.

    var/ban$ cat 192.168.2.3
    3
    var/ban$ cat 192.168.15.3
    1

The second daemon in this system is easy2ban-ipban.
It monitors the ban files and bans the host by creating iptables rules.
It also takes care of decrementing the time left and releasing bans.

The following examples are run from the root of this project directory.
The $PATH will need to be set so that the programs in bin/ are found.

    $ PATH=bin/:$PATH

A good example for becoming familiar with this system is to try
out the easy2ban-local script can be used to run easy2ban-rule on a
local.log file.

    (terminal 1)
    $ ./bin/easy2ban-local

Then in a second terminal start easy2ban-ipban.
Be sure to use the -v option so that verbose output is displayed.

    (terminal 2)
    $ ./bin/easy2ban-ipban -v

Then in a third terminal create some pattern log entries that will trigger
a match.

    $ echo "192.168.3.4 XXX" >> local.log
    $ echo "192.168.3.4 XXX" >> local.log
    $ echo "192.168.3.4 XXX" >> local.log

You should see ban files being created with their ban time.
And you should see the easy2ban-ipban daemon creating iptables rules
to ban these hosts.

    $ sudo iptables -vnL easy2ban

DESIGN
------

The design of this system is unique in several ways.

Interprocess communication is accomplished using the file system.
This allows the information to be viewed and modified using standard
file system utilities.  This also makes it easier to debug.
For example, suppose a IP was banned and you wanted to know how much
longer it would be banned for.  To find out just cat the ban file.

    $ cat var/ban/192.168.5.12
    15

Suppose an IP should be un-banned.  To do this just remove the file.

    $ rm var/ban/192.168.5.12

Typical log entries (/var/log) have an associated time.
To keep this system simple it is ignored entirely.
Instead, the rate of matches is kept track of in memory.
Since no substantial time calculations are needed during startup
it is very quick even with a large number of log files.

The source of logging data can be a file but it does not have to be.
It can also be a program the produces data.
This makes the system general and adaptable to new situations.

AUTHOR
------

Jeremiah Mahler <jmmahler@gmail.com><br>
<http://github.com/jmahler>

COPYRIGHT
---------

Copyright &copy; 2014, Jeremiah Mahler.  All Rights Reserved.<br>
This project is free software and released under
the [GNU General Public License][gpl].

 [gpl]: http://www.gnu.org/licenses/gpl.html

