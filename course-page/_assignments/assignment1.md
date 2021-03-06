---
title: Assignment 1 - Network Calculator
date: 2014-09-25 08:15:00
due: 2014-10-17 23:59:00

summary: "<p>Texas Instruments has a problem: no one wants a simple TI-83 calculator anymore that performs their calculations for them on the spot. Nay, they want an Internet-connected device that will submit mathematical expressions to a server. The server will then evaluate their expressions and return the results back to their device. Who cares about efficiency and speed? This is 2014. Connectivity is where it's at.</p>
<p>
In this assignment, you'll write two programs: a calculator client and a calculator server. The client will take a mathematical expression specified by a user on the command line and submit it over the network to the server. The server will then evaluate the expression, and return the result back to the client where it will be displayed to the user.
</p>
"
---

<div class="panel-body">

  <p>
    Texas Instruments has a problem: no one wants a simple TI-83 calculator
    anymore that performs their calculations for them on the spot.  Nay, they
    want an Internet-connected device that will submit mathematical
    expressions to a server.  The server will then evaluate their expressions
    and return the results back to their device.  Who cares about efficiency
    and speed?  This is 2014.  Connectivity is where it's at.
  </p>

  <p></p>
    In this assignment, you'll write two programs: a calculator client and a
    calculator server.  The client will take a mathematical expression
    specified by a user on the command line and submit it over the network to
    the server.  The server will then evaluate the expression, and return the
    result back to the client where it will be displayed to the user.
  <p></p>

  <div class="mb10"></div>

  <h4>Goals</h4>

  <p>The purpose of this assignment is to:</p>

  <ul>
    <li>Get a relatively gentle introduction to TCP socket programming</li>
    <li>Better understand the client/server architecture</li>
    <li>Gain experience implementing a simple application-layer protocol</li>
    <li>Practice software development in C, including paying attention to good style and coding practices</li>
  </ul>

  <h4 style="margin-top: 20px">Our Application Layer Protocol: CTP</h4>

  <p>For our calculator client and server to communicate, we'll need an application-layer protocol that
  we'll call the <em>Calculation Transport Protocol (CTP)</em>.  Like HTTP, this protocol has only
  two message types: a request message and a response message.  Both message types are composed simply
  of ASCII text.  Also like HTTP, CTP will use the Transmission Control Protocol (TCP) as its underlying
  transport-layer protocol.</p>

  <h5 style="margin-top: 20px">CTP Request</h5>

  <p>A CTP request is sent by a CTP client and consists of a single line:</p>

  <pre><code>&lt;expression&gt;&lt;cr&gt;&lt;lf&gt;</code></pre>

  <p>That is, it simply sends the expression to be evaluated, followed by a carriage return and linefeed.  For example,</p>
  
  <pre><code>(( 2 + 5 ))/10\r\n</code></pre>

  <p>The maximum length of an expression is 78 characters.  Hence the maximum length of a CTP request is
  80 characters: 78 characters for the expression, a carriage return, and a linefeed.</p>

  <h5 style="margin-top: 20px">CTP Response</h5>

  <p>The format of a CTP response message will differ depending on whether or not the request was valid.
  If the request contains a valid expression, the response message will be as follows:</p>
  
  <pre><code>Status:&lt;space&gt;&lt;code&gt;&lt;cr&gt;&lt;lf&gt;
Result:&lt;space&gt;&lt;result&gt;&lt;cr&gt;&lt;lf&gt;</code></pre>

  <p>For example, a response for a successful request might be:</p>

  <pre><code>Status: ok\r\n
Result: 1\r\n</code></pre>

  <p>If the request was invalid, the response will contain only a single line:</p>
  
  <pre><code>Status:&lt;space&gt;&lt;code&gt;&lt;cr&gt;&lt;lf&gt;</code></pre>

  <p>For instance,</p>

  <pre><code>Status: invalid-expr\r\n</code></pre>

  <p>
    When a CTP server receives a CTP request message, it must:
  </p>
  
  <ol>
    <li>
    Check that the message is a correctly structured CTP request message (i.e. it contains a
    non-empty expression terminated by a carriage return and linefeed).
      <ul><li>If not, it should return the status code <code>malformed-req</code></li></ul>
    </li>
    <li>Check that the expression is at most 78 characters.
      <ul><li>If not, it should return the status code <code>max-length-exceeded</code></li></ul>
    </li>
    <li>
      Parse the expression
      <ul>
        <li>If the expression contains mismatched parentheses, it should return the status code <code>mismatch</code></li>
        <li>If the expression contains invalid characters (discussed shortly) or otherwise cannot be parsed (e.g. <code>5--</code>), it should return the status code <code>invalid-expr</code></li>
      </ul>
    </li>

    <li>Evaluate the expression and return it to the client with the status code <code>ok</code>.</li>
  </ol>

  <p>Notes about parsing expressions:</p>

  <ul>
    <li>The only valid characters in an expression are: <code>+ - * / &lt;space&gt; ( ) 0-9</code></li>
    <li>Only integer arithmetic is supported, and the mere presence of a <code>.</code> in an
    expression should result in a status code of <code>invalid-expr</code>.</li>
    <li>The only mathematical operations supported by the server are: <code>+</code>, <code>-</code>, <code>*</code>, <code>/</code> (integer division).</li>
    <ul>
      <li>Integer division example: <code>5 / 2 = 2</code> (not <code>2.5</code>)</li>
    </ul>

    <li>The unary negation operator must also be handled, e.g. <code>-5 + 9</code></li>

    <li>The server should be able to handle expressions containing nested parentheses, e.g. <code>((5+2)/(4-(-3)))</code></li>
 </ul>

 <div class="mb20"></div>

 <h5>Summary of Response Codes</h5>

 <table class="table">
   <thead>
     <tr>
       <th>Response Code</th>
       <th>Description</th>
     </tr>
   </thead>
   <tbody>
     <tr>
       <td><code>ok</code></td>
       <td>Request successful; response contains result of evaluating the expression</td>
     </tr>
     <tr>
       <td><code>malformed-req</code></td>
       <td>Request message was not structured correctly</td>
     </tr>
     <tr>
       <td><code>max-length-exceeded</code></td>
       <td>Expression was longer than 78 characters</td>
     </tr>
     <tr>
       <td><code>mismatch</code></td>
       <td>Expression contained mismatched parentheses</td>
     </tr>
     <tr>
       <td><code>invalid-expr</code></td>
       <td>Expression contained an invalid character (e.g. <code>%</code>) or could not be parsed (e.g. <code>5--</code>)</td>
     </tr>
   </tbody>
 </table>

  <h4>The Client</h4>

  <p>The client is a simple program that takes input from the user through command-line parameters,
  sends a CTP request to the server, and displays the response from the server.</p>

  <h5>Command-Line Parameters</h5>

  <p>The client must use the <code>getopt_long</code> function (see Lab 2) to support the following command-line parameters:</p>

  <table class="table">
    <thead>
      <tr>
        <th>Parameter</th>
        <th>Description</th>
        <th>Example</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><code>-s</code></td>
        <td>The hostname or IP address of the calculator server</td>
        <td><code>-s server.hostname.com</code></td>
      </tr>
      <tr>
        <td><code>--server</code></td>
        <td>Same as <code>-s</code></td>
        <td><code>--server server.hostname.com</code></td>
      </tr>
      <tr>
        <td><code>-p</code></td>
        <td>The port on which the server is listening</td>
        <td><code>-p 9000</code></td>
      </tr>
      <tr>
        <td><code>--port</code></td>
        <td>Same as <code>-p</code></td>
        <td><code>--port 9000</code></td>
      </tr>
      <tr>
        <td><code>-e</code></td>
        <td>The expression to evaluate</td>
        <td><code>-e '2*5'</code></td>
      </tr>
      <tr>
        <td><code>--expr</code></td>
        <td>Same as <code>-e</code></td>
        <td><code>--expr '2*5'</code></td>
      </tr>
    </tbody>
  </table>

  <p>All listed options are required.  If any are missing (server, port, or expression), an error
  message should be printed and the program should exit.</p>
 
  <h5>Handling CTP Responses</h5>

  <p>The client should parse the response from the CTP server and display the response in the form:</p>

  <pre><code>Status Code: &lt;code&gt;
Result: &lt;result&gt;</code></pre>

  <p>You can assume that the response from the server will be well-formed, so you do not need to 
  perform error checking to ensure it has sent a correctly structured message.</p>

  <h5>Sample Requests</h5>

  <pre><code># Build the code
$ make

# Specifying the server by hostname
$ ./calc-client --server server.hostname.com --port 9000 --expr "((50+2)/4)-3"
Status Code: ok
Result: 10

# Specifying the server by IP address
$ ./calc-client --server 1.2.3.4 --port 9000 --expr "((50 + 2) / 4) - 3"
Status Code: ok
Result: 10

# Mismatched parentheses
$ ./calc-client --server server.hostname.com --port 9000 --expr "((50*2)/4"
Status Code: mismatch

# Invalid character
$ ./calc-client --server server.hostname.com --port 9000 --expr "50$2"
Status Code: invalid-expr

# Invalid expression
$ ./calc-client --server server.hostname.com --port 9000 --expr "1**9"
Status Code: invalid-expr

# Floating point
$ ./calc-client --server server.hostname.com --port 9000 --expr "50.1 + 5"
Status Code: invalid-expr
</code></pre>


  <h4>The Server</h4>

  <p>The server listens on the specified port for CTP requests.  Upon receiving a request, it processes
  it according to the rules set forth earlier, and returns a response message back to the client.</p>

  <h5>Command-Line Parameters</h5>

  <p>The server must use the <code>getopt_long</code> function to support the following command-line
  parameters:</p>

  <table class="table">
    <thead>
      <tr>
        <th>Parameter</th>
        <th>Description</th>
        <th>Example</th>
      </tr>
    </thead>
    <tbody>
      <tr>
      </tr><tr>
        <td><code>-p</code></td>
        <td>The port on which the server should listen</td>
        <td><code>-p 9000</code></td>
      </tr>
      <tr>
        <td><code>--port</code></td>
        <td>Same as <code>-p</code></td>
        <td><code>--port 9000</code></td>
      </tr>
    </tbody>
  </table>

  <p>The <code>-p</code> / <code>--port</code> option is required.  If missing, an error
  message should be printed and the program should exit.</p>

  <p>Assuming the port is specified, the server should open a TCP socket and begin listening on
  the specified port.</p>
 
  <h5>Server Output</h5>

  <p>As noted above, the server will be passed the port number on which to listen as a command-line
  argument:</p>

  <pre><code># Build the code
$ make

# Start the server
$ ./calc-server --port 9000</code></pre>

  <p>The server must use the Syslog facility (see Lab 2) and output reasonable messages to the screen to allow
  someone watching it in operation to be able to determine what it is currently doing.  At a minimum,
  each incoming request should be logged with the client's IP address, the expression sent, the
  status code returned to the client, and the result of evaluating the expression, if the expression
  was valid.</p>

  <p>For instance, your log output might look something like this (but you can use a different format,
  as long as it is clean and readable):</p>

<pre><code>Sep 25 05:30:34 cs3357 calc-server[9472]: Request received from client 1.1.1.1
Sep 25 05:30:34 cs3357 calc-server[9472]: Expression was: (5+2)/10        
Sep 25 05:30:34 cs3357 calc-server[9472]: Status: ok, result: 1</code></pre>

  <div class="mb20"></div>

  <h4>Hints</h4>

  <ul>
    <li>Start with the server first.  It represents the majority of the assignment.
        It is also quite easy to test the server even before you have the client built: just as you can Telnet to an HTTP server, you can Telnet to your CTP server and issue requests manually to help you test its functionality.</li>

        <li>Think back to first-year Computer Science.  What data structure can we use to parse a mathematical expression (also known as an <em>infix expression</em>)?  Once you figure that out, go download an implementation of that data structure in C and use it.  This is not a data structures course.  Make sure you cite your sources, however, in a comment at the top of the code.  Failure to cite your sources will be treated as an academic offense.
        <ul>
          <li>This is the only external code you may use.</li> 
        </ul>
        </li>

     <li>You have plenty of examples of working with Getopt and Syslog in Lab 2.  Make use of them.</li>

     <li>Lab 3 will cover TCP socket programming.  If you want to get started before Lab 3 is released,
     check out the <em>very</em> readable <a href="http://beej.us/guide/bgnet/">Beej's Guide to Network Programming</a>.  It is available for free in HTML and PDF formats.</li>

     <li>Start soon.  This assignment is not extremely difficult, but socket programming is likely new to you, and you may not be an expert in C programming (yet).</li>

   </ul>

  <div class="mb20"></div>

  <h4>General Requirements</h4>

  <ul>
    <li>It must be possible to build both the client and server at the same time, simply by typing <code>make</code>; this 
    implies that you'll need to create a basic <code>Makefile</code>.</li>

    <li>The <code>Makefile</code> should build two executables: <code>calc-client</code> and <code>calc-server</code>.  Make sure you adhere to these naming conventions.  We have one TA marking 50+ assignments, and it slows down the whole process when everyone uses a different name for their executables.  It also prevents us from running automated tests.</li>

    <li>The client and server must run in the CS 3357 virtual machine.</li>

    <li>Both the client and server must be written in standard C (to be exact, in C90 with GNU extensions, which is the default mode that <code>gcc</code> provides when you don't specify a standard).  You may not use C99, C++, Objective C, or any other dialects, extensions, or languages.</li>

    <li>Yes, you do need to comment your code.  Sorry.  It sucks, but it's necessary.
    <ul>
      <li>Your code should contain a reasonable amount of inline comments to allow someone to follow your algorithms.</li>
      <li>Variable declarations should be commented, describing the purpose of the variables.</li>
      <li>Each file (both <code>.c</code> and <code>.h</code> should contain a header comment at the top of the file including, at a minimum: the filename, a description of the file, the course code, the assignment number, your name, and your email address.  For instance,


      <pre><code>/********************************************************************************
 * calc-client.c
 * 
 * Computer Science 3357a
 * Assignment 1
 *
 * Author: Jeff Shantz <jeff@csd.uwo.ca>
 * 
 * Brief description of the file goes here.
*******************************************************************************/</jeff@csd.uwo.ca></code></pre>
      </li>
    </ul>

    </li><li>Good coding practices should be followed, such as declaring constants (<code>#define</code>) instead of using magic numbers; adhering to good variable and function naming practices; etc.  Your functions and files should be of a reasonable size.  If your whole program is implemented in one function (or even one file), or if we find 50-line functions in your code, that's going to be affect your style mark.  Strive for modularity.</li>

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
    <li>The final commit representing your submission must be tagged <code>asn1</code> — <strong>don't forget to push the tag to GitHub.  Your assignment is not submitted until that tag is pushed to GitHub.</strong></li>
    <li>The assignment should reside within a directory <code>asn1</code> in the <em>root</em> of your GitHub repository.</li>
    <li>Your <code>asn1</code> directory should contain only <code>.c</code> files, <code>.h</code> files, and a <code>Makefile</code>.  If you like, you may also include a file named <code>README</code> in your <code>asn1</code> directory in the event that you have something you wish to pass along to the TA.</li>
    <li>To organize your code better, you may arrange your code into subdirectories, but your <code>Makefile</code> should exist in the <code>asn1</code> directory, and it should produce the executables <code>calc-client</code> and <code>calc-server</code> in the <code>asn1</code> directory itself (not in a subdirectory).</li>
  </ul>

  <h4>FAQ</h4>

  <hr>

  <h5>
    <i class="fa fa-question-circle"></i>
    Question 1<br>
    <small style="padding-left: 17px">October 04, 2014 at 05:00</small>
  </h5>

  <hr>

  <blockquote>

    <p>
      <i class="fa fa-quote-left"></i> 
      Can you clarify the possible ways in which the unary operator can appear?  For example, are
      the following valid?
    </p>
  
    <ul>
      <li><code>"-(5)"</code></li>
      <li><code>"-(-(5 + 5))"</code></li>
      <li><code>"5 * -5"</code></li>
      <li><code>"-5 * 5"</code></li>
      <li><code>"5 / -5"</code></li>
    </ul>
  
    <p>Can a unary operator also come before a space?  For example,</p>
  
    <ul>
      <li><code>"- 5"</code></li>
      <li><code>"-   (5)"</code></li>
    </ul>
  
    <p>Can unary operators be applied consecutively?  For example,</p>
    
    <ul>
      <li><code>"---5" = -5</code></li>
    </ul>
  
    <p>Can a unary operator come after addition or subtraction?  For example,</p>
    
    <ul>
      <li><code>"5 + -5" = 0</code></li>
      <li><code>"5 - -5" = 10</code></li>
    </ul>

  </blockquote>

  <hr>

  <h5>
    <i class="fa fa-bullhorn"></i>
    Answer 1
  </h5>

  <hr>

  <div class="answer">
  <p>
    Yes, to all questions above.  They are all valid and accepted by the parser I wrote,
    which implements a popular expression parsing algorithm.
  </p>
  </div>

  <hr>

  <h5>
    <i class="fa fa-question-circle"></i>
    Question 2<br>
    <small style="padding-left: 17px">October 04, 2014 at 05:05</small>
  </h5>

  <hr>

  <blockquote>
    <p>
      <i class="fa fa-quote-left"></i> 
      It indicates in the hints section that I have to download the
      implementation of a data structure in C to parse expressions. Underneath,
      it states:
    </p>

    <p>"This is the only external code you may use."</p>

    <p>Does it mean that I have to get the data structure from the web to use
    it for expression parsing or do I have to make my own data structure of
    the expression parser?
    </p>
  </blockquote>

  <hr>

  <h5>
    <i class="fa fa-bullhorn"></i>
    Answer 2
  </h5>

  <hr>

  <div class="answer">
  <p>
    In class, we discussed a data structure that would be useful for parsing
    expressions.  As the assignment states, you may download an implementation
    of that data structure and use it in your program.  Note that it does <em>not</em>
    state that you may download any code to actually parse the expressions.
    You have to write that code yourself.
  </p>
  
  <p>
     The idea is that you may download a plain, vanilla data structure to save
     the hassle of having to implement it yourself (not that it's difficult or
     even overly time-consuming).  If you choose to download a pre-implemented data
     structure, it should be properly cited.  Failing to cite your source
     or using any other external code than a simple data structure is an
     academic offense.  "I didn't know" isn't a valid excuse.  Either ask, or 
     write the code yourself.  If I sound harsh, it's just that I'm trying to
     be very clear, since apparently what I originally wrote was not clear to
     some.
  </p>

  <p>
    If you'd prefer to implement the data structure yourself, that's perfectly
    fine.  In fact, I encourage it.
  </p>

  </div>

  <hr>

  <h5>
    <i class="fa fa-question-circle"></i>
    Question 3<br>
    <small style="padding-left: 17px">October 12, 2014 at 00:10</small>
  </h5>

  <hr>

  <blockquote>
    <p>
      <i class="fa fa-quote-left"></i> 
      What do we do in the event of division by zero?
    </p>
  </blockquote>

  <hr>

  <h5>
    <i class="fa fa-bullhorn"></i>
    Answer 3
  </h5>

  <hr>

  <div class="answer">
  <p>
    Since I forgot to address this in the assignment spec, you can assume we will not test for it.
    You may choose to do anything reasonable, such as returning <code>infinity</code>, but your 
    program should not crash.
  </p>

</div>

</div>
