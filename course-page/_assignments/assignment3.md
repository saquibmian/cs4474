---
title: "Assignment 3: Head in the Cloud"
date: 2014-11-25 08:15:00
due: 2014-10-17 23:59:00

summary: "
<p>
We've now had experience implementing both an ASCII and a binary protocol.
The protocols we've implemented to date, however, have been custom protocols.
We've also been working exclusively in a virtual machine, running both our clients
and servers in the same machine.
</p>
<p>Being a networking course, we would be remiss if we didn't actually try implementing
a real protocol, and didn't actually test out said protocol over a real network.
</p>
<p>In this assignment, then, you'll set up a server (called an <em>instance</em>) in
the cloud using Amazon EC2.  On this system, you'll install an application-layer server
of your choice: a DNS server or an IRC server.
</p>
<p>You'll then write a simple client in C to interact with this server to give you experience
implementing a well-known protocol.</p>
"
---

<div class="contentpanel">
                <div class="row">

  <div class="asn panel panel-default">

    <div class="panel-body">

      <p>
        We've now had experience implementing both an ASCII and a binary protocol.
        The protocols we've implemented to date, however, have been custom protocols.
        We've also been working exclusively in a virtual machine, running both our clients
        and servers in the same machine.
      </p>
      
      <p>Being a networking course, we would be remiss if we didn't actually try implementing
      a "real" protocol, and didn't actually test out said protocol over a real network.
      </p>

      <p>In this assignment, then, you'll set up a server (called an <em>instance</em>) in
      the cloud using Amazon EC2.  On this system, you'll install an application-layer server
      of your choice: a DNS server or an IRC server.
      </p>

      <p>You'll then write a simple client in C to interact with this server to give you experience
      implementing a well-known protocol.</p>

      <div class="mb10"></div>

      <h4>Goals</h4>

      <p>The purpose of this assignment is to:</p>

      <ul>
        <li>
          Learn about basic cloud computing
        </li>
        <li>
          Gain experience reading an RFC and implementing a well-known protocol
        </li>
        <li>
          Gain additional experience with socket programming in C
        </li>
        <li>
          Practice software development in C, including paying attention to good style
          and coding practices
        </li>
      </ul>

      <h4 style="margin-top: 20px">Step 1: Set Up Your Cloud Instance</h4>

      <p>
        Complete <a href="/cs3357/labs">Lab 6</a> to set up your Amazon EC2 instance.
        This should take approximately 20-30 minutes.
      </p>

      <p>
        Note that this step is not technically part of this assignment.  You need your instance
        to complete your assignment, but the assignment will not include marks for setting up
        the instance, since you are already getting a mark for it by completing lab 6.
      </p>

      <h4 style="margin-top: 20px">Step 2: Choose a Protocol</h4>

      <p>You have a choice of the protocol you'd like to work with in this assignment.  The
      table below lists your possible choices, along with an estimate of the difficulty of implementing
      a client for each choice.</p>

      <table class="table table-striped table-bordered">
        <thead>
          <tr>
            <th>Protocol</th>
            <th>Difficulty of Implementing a Client</th>
            <th>Bonus Marks Available</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>HyperText Transfer Protocol (HTTP)</td>
            <td>Light-Medium</td>
            <td>None</td>
          </tr>
          <tr>
            <td>Domain Name System (DNS)</td>
            <td>Medium-Heavy</td>
            <td>Up to 30%</td>
          </tr>
          <tr>
            <td>Internet Relay Chat (IRC)</td>
            <td>Heavy (multithreaded programming required)</td>
            <td>Up to 30%</td>
          </tr>
          <tr>
            <td>Another protocol?  Clear it with Jeff first (not SMTP, however).</td>
            <td>Medium-Heavy?</td>
            <td>Depends on the protocol chosen</td>
        </tr></tbody>
      </table>

      <p>If you'd like to work with a different protocol, you must clear it with your instructor first.
      Please note that SMTP will not be allowed.  SMTP can get us into trouble if you set up an open relay and accidentally allow spammers to use your SMTP server.</p>

      <h4 style="margin-top: 20px">Step 3: HTTP Option - Implement an HTTP Client</h4>

        <h5>Server</h5>

        <p>Lab 6 already covered the installation of an HTTP server.</p>
        
        <p>Create two files, <code>get.html</code> and <code>post.html</code> accessible from the server's <em>document root</em>:</p>

        <ul>
          <li><code>http://x.y.z.w/get.html</code></li>
          <li><code>http://x.y.z.w/post.html</code></li>
        </ul>

        <p>Both files should present a form to the user:</p>

        <img src="/cs3357/assignments/asn3/files/form.png">

        <p>Both forms should submit values to a CGI script you will write (see below), but 
        <code>get.html</code> should use a form action of <code>GET</code>, while <code>post.html</code>
        should use a form action of <code>POST</code>.</p>

        <p>Next, look up at a tutorial on writing a CGI script in the language of your code
        (typical languages include Perl, Python, Ruby).  The script should:</p>

        <ul>
          <li>Be named <code>form.cgi</code></li>
          <li>Be located in your document root.  For example, if your server is <code>1.1.1.1</code>, then your script should be accessible at <code>http://1.1.1.1/form.cgi</code></li>
          <li>Take parameters sent in a <code>GET</code> or <code>POST</code> request and write them to a file <code>{documentroot}/lastrequest/params.txt</code>.<p></p>
          </li><li>Print the message <code>Thank you</code> to the user.</li>
        </ul>

        <p>The format of the file should be:</p>

        <pre><code>param1: value
param2: value
.
.</code></pre>

        <p>For example, if I were to submit a <code>GET</code> request to <code>http://1.1.1.1/form.cgi?fname=jeff&amp;lname=shantz&amp;level=phd</code>, then the file <code>http://1.1.1.1/lastrequest/params.txt</code> should
        contain:</p>

        <pre><code>fname: jeff
lname: shantz
level: phd</code></pre>

        <p>Use your <code>get.html</code> and <code>post.html</code> forms to test your script.  Be sure
        that <code>lastrequest/params.txt</code> has its permissions set appropriately so that it is 
        readable via the Web.</p>

        <h5>Client</h5>

        <p>We saw in class that HTTP is a simple binary protocol that uses TCP as its underlying 
        transport protocol.  Write a simple HTTP client <code>htc</code> that implements the following command line options:</p>

        <pre><code>htc [-t|--type TYPE] [-p|--param NAME=VALUE ...] SERVER PATH</code></pre>

        <p>By default, the client will submit a <code>GET</code> request to <code>http://SERVER/path</code> and display the server's response (you do not need to parse the HTML response):</p>
        
        <pre><code># Send a GET request to http://www.csd.uwo.ca/index.html
$ ./htc www.csd.uwo.ca /index.html
(HTML response displayed)

# Send an explicit GET request for http://www.csd.uwo.ca/index.html
$ ./htc -t GET www.csd.uwo.ca /index.html
(HTML response displayed)

# Send a GET request to http://1.1.1.1/form.cgi?fname=jeff&amp;lname=shantz&amp;level=phd
$ ./htc -t GET -p name=jeff -p lname=shantz -p level=phd 1.1.1.1 /form.cgi
(HTML response displayed)

# Send a POST request to http://1.1.1.1/form.cgi
$ ./htc -t POST -p name=jeff -p lname=shantz -p level=phd 1.1.1.1 /form.cgi
(HTML response displayed)</code></pre>
          
        <p>Your client should <strong>not</strong> print the HTTP headers returned from the server — only the contents of the entity body.  It does not need to download any referenced objects in the returned HTML.</p>

        <p>If the server returns a response code other than a 200-level code, the client should print:</p>

        <code>Error: status code XXX</code>

        <p>where XXX is the status code.  For example:</p>

        <pre><code># Send a GET request for a non-existent page
$ ./htc www.csd.uwo.ca index55.html
Error: status code 404</code></pre>

        <p>Be sure to test your client with your server, but also with a regular HTTP server like <code>www.csd.uwo.ca</code> to ensure that it is working properly.</p>

        <p>Be sure to include a Makefile that builds an executable called <code>htc</code>.  As usual,
        command line parameters must be parsed with <code>getopt_long</code>.</p>

        <h5>Resources</h5>

        <table class="table table-striped table-bordered">
          <thead>
            <tr>
              <th>Resource</th>
              <th>Description</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><a href="http://tools.ietf.org/html/rfc7230">RFC 7230</a></td>
              <td>Section 3 covers the HTTP message format</td>
            </tr>
            <tr>
              <td><a href="http://tools.ietf.org/html/rfc7231">RFC 7231</a></td>
              <td>Section 4 covers the different types of requests (we are only implementing GET and POST).</td>
            </tr>
            <tr>
              <td><a href="https://docs.python.org/2/library/cgi.html">CGI in Python</a></td>
              <td>Information on writing a CGI script in Python.  You can use any language you please.</td>
            </tr>
            <tr>
              <td><a href="http://www.linux.com/community/blogs/129-servers/757148-configuring-apache2-to-run-python-scripts">Configuring Apache2 to run Python Scripts</a></td>
              <td>A short tutorial showing how your Apache configuration must be modified to run a CGI script written in Python.</td>
            </tr>
          </tbody>
        </table>

      <h4 style="margin-top: 20px">Step 3: DNS Option - Implement a DNS Client</h4>

        <h5>Server</h5>

        <p>Look up a tutorial on BIND and install it in your instance.  The server will host DNS records
        for the fake domain <code>cs3357.fake</code>.</p>
        
        <p>Configure the server with the following (fake) records:</p>
        
        <table class="table table-striped table-bordered">
          <thead>
            <tr>
              <th>Record Type</th>
              <th>Name</th>
              <th>Value</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><code>NS</code></td>
              <td><code>cs3357.fake</code></td>
              <td><code>ns1.cs3357.fake</code></td>
            </tr>
            <tr>
              <td><code>A</code></td>
              <td><code>ns1.cs3357.fake</code></td>
              <td><em>Your instance's public IP address</em></td>
            </tr>
            <tr>
              <td><code>A</code></td>
              <td><code>cs3357.fake</code></td>
              <td><code>10.0.0.1</code></td>
            </tr>
            <tr>
              <td><code>A</code></td>
              <td><code>mail.cs3357.fake</code></td>
              <td><code>10.0.0.2</code></td>
            </tr>
            <tr>
              <td><code>CNAME</code></td>
              <td><code>www.cs3357.fake</code></td>
              <td><code>cs3357.fake</code></td>
            </tr>
            <tr>
              <td><code>MX</code></td>
              <td><code>cs3357.fake</code></td>
              <td><code>mail.cs3357.fake</code></td>
            </tr><tr>
              <td><code>TXT</code></td>
              <td><code>cs3357.fake/code&gt;</code></td>
              <td><em>Your Western username</em></td>
            </tr>
          </tbody>
        </table>

        <p><strong>Note: make <u>sure</u> you disable recursive queries on your server.  Otherwise, 
          attackers on the Internet will be able to use your server to launch DNS amplification attacks
          and we could get into trouble from Amazon for this.</strong></p>

        <p>Don't worry about configuring reverse mappings, as discussed in the tutorials.</p>

        <p>You can test your server using the <code>nslookup</code> and <code>dig</code> commands.
        For example:</p>

        <pre><code>$ dig @127.0.0.1 -t MX cs3357.fake      # Get the MX record for cs3357.fake
$ dig @127.0.0.1 -t TXT cs3357.fake     # Get the TXT record for cs3357.fake
$ nslookup 
&gt; server 127.0.0.1
Default server: 127.0.0.1
Address: 127.0.0.1#53
&gt; www.cs3357.fake
Server:         127.0.0.1
Address:        127.0.0.1#53

www.cs3357.fake canonical name = cs3357.fake.
Name:    cs3357.fake
Address: 10.0.0.1</code></pre>

        <p>Don't forget to open the appropriate port in your EC2 security group!</p>

        <h5>Client</h5>

        <p>We saw in class that DNS is a simple binary protocol that uses UDP as its underlying 
        transport protocol.  Write a DNS client <code>nsl</code> that implements the following command line options:</p>

        <pre><code>nsl [-t|--type TYPE] DNSSERVER QUERY</code></pre>

        <p>By default, the client will query <code>DNSSERVER</code> for an <code>A</code> record matching
        <code>QUERY</code>.  For example:</p>

        <pre><code>./nsl 8.8.8.8 www.google.com
Name:www.google.com
Address: 173.194.46.113</code></pre>

        <p>Note that, as shown above, if multiple records are returned, only the <strong>first</strong>
        returned record need be displayed.</p>

        <p><strong>This is all the functionality you need to implement.</strong>  If you want to obtain up to 30% in bonus marks, you can implement support for other records by allowing the user to specify the type of records he/she wishes to retrieve using the <code>-t</code>/<code>--type</code> option:</p>

        <pre><code>./nsl -t MX 8.8.8.8 google.com           # Prints the MX records for google.com
./nsl -t CNAME 8.8.8.8 www.csd.uwo.ca    # Prints the CNAME for www.csd.uwo.ca
.
.
.</code></pre>

        <p>Your client should then present the server's response in an intuitive and easily comprehensible
        manner (similar to the output of <code>nslookup</code> or <code>dig</code>).</p>

        <p>Ideally, the user should be able to query any type of DNS record using the <code>-t</code>/<code>--type</code> flag, but, at a minimum, your client should support queries for <code>A</code>, <code>CNAME</code>, 
        <code>MX</code>, and <code>TXT</code> records.</p>

        <p>Be sure to test your client with your server, but also with a regular DNS server like <code>8.8.8.8</code> to ensure that it is working properly.</p>

        <p>Be sure to include a Makefile that builds an executable called <code>nsl</code>.  As usual,
        command line parameters must be parsed with <code>getopt_long</code>.</p>

        <h5>Resources</h5>

        <table class="table table-striped table-bordered">
          <thead>
            <tr>
              <th>Resource</th>
              <th>Description</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><a href="https://www.digitalocean.com/community/tutorials/how-to-configure-bind-as-a-private-network-dns-server-on-ubuntu-14-04">Tutorial on Installing/Configuring BIND on Ubuntu</a></td>
              <td>A guide to installing and configuring BIND in Ubuntu (the Linux distribution you're using in your EC2 instance).</td>
            </tr>
            <tr>
              <td><a href="http://wiki.linux-nfs.org/wiki/index.php/Fake_DNS_Realm">Fake DNS Realm</a></td>
              <td>Another bind tutorial showing the set up of a fake domain using BIND.  Note that this tutorial is for a different distribution of Linux, so the paths of the various files mentioned in the tutorial are different on Ubuntu.</td>
            </tr>
             <tr>
               <td><a href="http://www.zytrax.com/books/dns/">DNS for Rocket Scientists</a></td>
               <td>A comprehensive guide to BIND</td>
             </tr>
            <tr>
              <td>
                <ul>
                  <li><a href="http://www.zytrax.com/books/dns/ch8/a.html">A records</a></li>
                  <li><a href="http://www.zytrax.com/books/dns/ch8/txt.html">TXT records</a></li>
                  <li><a href="http://www.zytrax.com/books/dns/ch8/ns.html">NS records</a></li>
                  <li><a href="http://www.zytrax.com/books/dns/ch8/mx.html">MX records</a></li>
                  <li><a href="http://www.zytrax.com/books/dns/ch8/cname.html">CNAME records</a></li>
                </ul>
              </td>
              <td>The format to use for the various records in your BIND configuration file.</td>
             </tr>
            <tr>
              <td><a href="https://www.ietf.org/rfc/rfc1035.txt">RFC 1035</a></td>
              <td>Use this as a reference for implementing your client.  You do not need to read the entire
                RFC.  In particular, sections 3 (page 10) and 4 (page 25) should be useful to you.<p></p>
              </td>
            </tr>
            <tr>
              <td>Lab 4</td>
              <td>Use the UDP socket library developed in this lab to speed your development.</td>
            </tr>
            <tr>
              <td>Lab 5</td>
              <td>DNS is a binary protocol.  Lab 5 covers binary protocols, along with endianness.</td>
            </tr>
            <tr>
              <td><a href="http://www.howtogeek.com/104278/how-to-use-wireshark-to-capture-filter-and-inspect-packets/">Wireshark tutorial</a></td>
              <td>You'll want to use Wireshark when debugging the interaction between your DNS client and server.</td>
            </tr>
          </tbody>
        </table>
        
      <div class="mb20"></div>

      <h4 style="margin-top: 20px">Step 3: IRC Option - Implement an IRC Client</h4>

      <div class="alert alert-success">
        Thanks to Brett for suggesting the IRC option.
      </div>

        <h5>Server</h5>

        <p>Look up a tutorial on installing <code>ircd-irc2</code>, and install it in your instance.  You can test your server using any regular IRC client.  Examples include <a href="http://www.mirc.com/">mIRC</a> (Windows), <a href="http://colloquy.info/">Colloquy</a> (OS X), and <a href="http://www.bitchx.com/">BitchX</a> (Linux).</p>

        <p>Don't forget to open the appropriate port(s) in your EC2 security group!</p>

        <h5>Client</h5>

        <p>Write a command-line IRC client.  The client should work in a manner similar to existing
        IRC clients.  At a minimum, it should be capable of:</p>

        <ul>
          <li>Connecting to a server and displaying its welcome message</li>
          <li>Allowing the user to join a channel using the <code>/join #channel</code> command</li>
          <li>Changing one's nickname using the <code>/nick NICKNAME</code> command</li>
          <li>Leaving a channel using the <code>/leave</code> command</li>
          <li>Quitting the server using the <code>/quit</code> command</li>
        </ul>

        <p>When the user has joined a channel, the client should be capable of:</p>

        <ul>
          <li>Displaying the list of users present in a channel</li>
          <li>Displaying the messages posted to the channel</li>
          <li>Posting a message to the channel by simply typing a message and pressing Enter</li>
        </ul>

        <p>Your client will need to be multi-threaded to both process user input and retrieve messages
        from the server simultaneously.</p>
        
        <p>The screen should be divided into sections as a regular IRC client
        does (i.e. the channel section, the user list, and the user input
        field).  The screenshot below shows the envisioned solution:</p>
        
        <img src="http://andychat.sourceforge.net/andychat0530-80x25-irc.jpg">
        
        <p>To accomplish this, you should look up a tutorial on the
        <code>ncurses</code> library, and make use of it to divide the screen into multiple panes.</p>

        <p>The syntax for running your client should be as follows:</p>

        <pre><code>ircc [-p|--port PORT] SERVER</code></pre>

        <p>where <code>SERVER</code> is required, and the <code>-p</code>/<code>--port</code> option is optional.  If not specified, the client should default to connecting to <code>SERVER</code> on port 6667 — the most commonly used IRC port.</p>

        <p>Be sure to include a Makefile that builds an executable called <code>ircc</code>.  As usual,
        command line parameters must be parsed with <code>getopt_long</code>.</p>

        <h5>Warning</h5>

        <p>The IRC option is <strong>not</strong> for the faint of heart.  If you
          choose to do an IRC client, you should ideally already know:</p>

        <ul>
          <li>What IRC is (ideally, you've used it in the past) so that you're familiar with how it works</li>
          <li>How to develop a multi-threaded program</li>
          <li>How to develop in C beyond a beginner's level</li>
        </ul>

        <p>If you don't meet the above criteria, you are strongly advised to choose the DNS client option instead.
        You have only two weeks to do this assignment, so don't sink yourself by taking on more than you
        can handle.  Those who are successful, however, will be rewarded with a bonus of up to 20% for
        the additional work that the IRC client will require.</p>

        <h5>Resources</h5>

        <table class="table table-striped table-bordered">
          <thead>
            <tr>
              <th>Resource</th>
              <th>Description</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><a href="https://tools.ietf.org/html/rfc2812">RFC 2812</a></td>
              <td>You do not need to read the entire RFC, but instead should use it as a reference.</td>
            </tr>
            <tr>
              <td><a href="https://help.ubuntu.com/lts/serverguide/irc-server.html">Tutorial on Installing/Configuring <code>ircd-irc2</code> on Ubuntu</a></td>
              <td>Useful when installing <code>ircd-irc2</code> in your EC2 instance.</td>
            </tr>
            <tr>
              <td><a href="http://tldp.org/HOWTO/NCURSES-Programming-HOWTO/">NCURSES Programming HOWTO</a></td>
              <td>Use this library to create multiple panes in your user interface</td>
            </tr>
          </tbody>
        </table>

      <h4>Hints</h4>

      <ul>
        <li>
          The first thing you should do upon encountering problems: fire up GDB
          (or another debugger).  When you come for help, I will require that
          you have tried to debug your code.  You <em>really</em> need to learn
          how to use a debugger.  It's time for tough love.  This is <em>basic</em>
          knowledge that employers expect.
        </li>
        <li>
          Don't forget about host order vs. network order!  See Lab 4.
        </li>
        <li>Start soon.</li>
      </ul>

      <div class="mb20"></div>

      <h4>General Requirements</h4>

      <ul>
        <li>
          It must be possible to build your code by simply typing <code>make</code>;
          this implies that you'll need to create a basic <code>Makefile</code>.
        </li>
        <li>
          The <code>Makefile</code> for the DNS client should build an executable <code>nsl</code>.
          The <code>Makefile</code> for the IRC client should build an executable <code>ircc</code>.
          Make sure you adhere to these naming conventions.
          We have one TA marking 50+ assignments, and it slows down the whole
          process when everyone uses a different name for their executables.  It
          also prevents us from running automated tests.
        </li>
        <li>The client must run in the CS 3357 virtual machine.</li>
        <li>Compile your code with <code>-Wall</code> — we will.</li>
        <ul><li>Repeat this mantra: warnings are errors.  Warnings are errors.  Warnings are errors.</li></ul>
        <li>Check your code for memory leaks using <code>valgrind</code> — we will.</li>
        <ul>
          <li>Install it with <code>sudo apt-get install valgrind</code></li>
          <li>Run it with <code>valgrind ./program [args]</code></li>
        </ul>
        <li>Files and sockets opened must be closed properly prior to exiting a program.</li>
        <li><strong>For this assignment, to reduce your end-of-year workload, we will not be marking style
          or comments.</strong>  With that said, we hope you hand in reasonably clean and modularized code.</li>
        <li>The client must be written in standard C (to be exact, in C90 with GNU extensions, which is the default mode that <code>gcc</code> provides when you don't specify a standard).  You may not use C99, C++, Objective C, or any other dialects, extensions, or languages.</li>
         <li>The assignment is intended to be completed individually.  You may discuss the assignment with others, but your work should be your own.  We reserve the right to run your code through automated similarity checking software.  Don't cheat.  You're just screwing yourself over.</li>

         <li>Please keep the length of your lines between approximately 80-100 characters.  This is a pretty standard guideline for most developers.</li>

         <li>Tabs are <strong>NEVER</strong> OK.  Set your editor to expand tabs to spaces.</li>

         <li>Set your indent width to between 2-4 characters.  8 characters of identation is <strong>way</strong> too much.</li>

         <li>Set your editor so that it places braces on a new line.  This is not Java.  In C, braces generally go on the next line.</li>

         <li>Yes, we're being nit-picky, but every company / development team out there adopts a set of style conventions and these are the conventions we're going to use for this course.</li>
       </ul>
        
                <h4>Submission Requirements</h4>

                <ul>
                  <li>Your assignment must be submitted in your GitHub repository by 23:59:59 on the due date.</li>
                  <li>The final commit representing your submission must be tagged <code>asn3</code> — <strong>don't forget to push the tag to GitHub.  Your assignment is not submitted until that tag is pushed to GitHub.</strong></li>
                  <li>The assignment should reside within a directory <code>asn3</code> in the <em>root</em> of your GitHub repository.</li>
                  <li>Your <code>asn3</code> directory should contain only <code>.c</code> files, <code>.h</code> files, and a <code>Makefile</code>.  If you like, you may also include a file named <code>README</code> in your <code>asn3</code> directory in the event that you have something you wish to pass along to the TA.</li>
                  <li>To organize your code better, you may arrange your code into subdirectories, but your <code>Makefile</code> should exist in the <code>asn3</code> directory, and it should produce the client executable (<code>nsl</code> or <code>ircc</code>) in the <code>asn3</code> directory itself (not in a subdirectory).</li>
                  <li>Notice that the directory name and tag are <code>asn3</code> — <em>not</em> <code>Assignment3</code>, <code>Asn3</code>, <code>Asmt3</code>, or anything else.</li>
                </ul>

              </div>

            </div>

          </div>

                <footer>
  <div class="row text-center">
    <p>This course is made possible by generous grants from:</p>

    <a href="http://www.github.com">
      <img class="sponsor-logo" src="/cs3357/images/logos/github.png">
    </a>

    <a href="http://aws.amazon.com">
      <img class="sponsor-logo" src="/cs3357/images/logos/aws.png">
    </a>

    <p class="copyright">All materials copyright © 2014, Jeff Shantz, except where indicated.</p>
  </div>
</footer>
              </div>