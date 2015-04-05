---
title: Assignment 2 - Reliable Data Transfer
date: 2014-10-14 08:15:00
due: 2014-11-14 23:59:00

summary: "
<p>
We've studied reliable data transfer and have seen algorithms that might
be implemented at the transport layer to ensure that data sent is
received correctly.  On the other hand, we've also seen that reliable
transport protocols like TCP incur greater overhead than unreliable
protocols like UDP, and are subject to the constraints of flow control
and congestion control.
</p>
<p>
What if we want the performance of UDP — with its low-overhead,
unreliable, no-frills service — but the reliability of TCP?  The
answer is that we're going to have to build in reliability at a higher
layer: the application layer!
</p>
<p>
In this assignment, you'll implement the Stop-and-Wait protocol to
transfer data reliably between two programs: a client
(<code>rftp</code>) and server (<code>rftpd</code>).  The client will
take a filename passed on the command line and upload the file to the
server using the UDP protocol.  To ensure that all data is received
reliably, the client will implement the sender side of the RDT 3.0
protocol discussed in class, while the server will implement the
receiver side.  Of course, Stop-and-Wait is not very efficient, but it
still gives us practice implementing a reliable data transfer
protocol without having to worry about multi-threading, as we would with
Go-Back-N or Selective Repeat.
</p>
<p>
Along the way, you'll see how to emulate a noisy channel in Linux, creating a <em>queueing discipline</em> that will corrupt, reorder, and lose packets.  In this way, you can accurately test the reliability of your programs and verify that you have correctly implemented the Stop-and-Wait protocol.
</p>
<p>
Note: if you took assignment 1 for granted, you probably found it to
be more work than you had expected.  I encourage you to get started on
this assignment as soon as possible.
</p>
"
---

<div class="contentpanel">
                <div class="row">

  <div class="asn panel panel-default">

    <div class="panel-body">

      <p>
        We've studied reliable data transfer and have seen algorithms that might
        be implemented at the transport layer to ensure that data sent is
        received correctly.  On the other hand, we've also seen that reliable
        transport protocols like TCP incur greater overhead than unreliable
        protocols like UDP, and are subject to the constraints of flow control
        and congestion control.
      </p>

      <p>
        What if we want the performance of UDP — with its low-overhead,
        unreliable, no-frills service — but the reliability of TCP?  The
        answer is that we're going to have to build in reliability at a higher
        layer: the application layer!
      </p>

      <p>
        In this assignment, you'll implement the Stop-and-Wait protocol to
        transfer data reliably between two programs: a client
        (<code>rftp</code>) and server (<code>rftpd</code>).  The client will
        take a filename passed on the command line and upload the file to the
        server using the UDP protocol.  To ensure that all data is received
        reliably, the client will implement the sender side of the RDT 3.0
        protocol discussed in class, while the server will implement the
        receiver side.  Of course, Stop-and-Wait is not very efficient, but it
        still gives us practice implementing a reliable data transfer
        protocol without having to worry about multi-threading, as we would with
        Go-Back-N or Selective Repeat.
      </p>

      <p>
        Along the way, you'll see how to emulate a "noisy" channel in Linux,
        creating a <em>queueing discipline</em> that will corrupt, reorder, and
        lose packets.  In this way, you can accurately test the reliability of
        your programs and verify that you have correctly implemented the
        Stop-and-Wait protocol.
      </p>

      <p>
        Note: if you took assignment 1 for granted, you probably found it to
        be more work than you had expected.  I encourage you to get started on
        this assignment as soon as possible.
      </p>

      <div class="mb10"></div>

      <h4>Goals</h4>

      <p>The purpose of this assignment is to:</p>

      <ul>
        <li>
          Learn about UDP socket programming
        </li>
        <li>
          Better understand reliable data transfer by implementing a reliable
          data transfer protocol
        </li>
        <li>
          See how a layer can add services on to the services provided by
          the layer below — in this case, building a reliable channel
          on top of an unreliable channel
        </li>
        <li>
          Gain experience implementing a binary application-layer protocol
        </li>
        <li>
          Practice software development in C, including paying attention to good style
          and coding practices
        </li>
      </ul>

      <h4 style="margin-top: 20px">Our Application Layer Protocol: RFTP</h4>

      <p>
        As we know, protocols govern all communication in computer networks.
        For our client and server to communicate, we'll once again need an
        application-layer protocol that we'll call the <em>Reliable File
        Transfer Protocol (RFTP)</em>.  RFTP will use the User Datagram
        Protocol (UDP) as its underlying transport-layer protocol, but will
        implement a variant of the RDT 3.0 protocol studied in class to add
        reliability on top of UDP.
      </p>

      <p>
        Unlike our CTP protocol from assignment 1, RFTP will be a
        <em>binary</em> protocol.  This seems to be a natural choice, since
        we're using UDP to maximize file transfer performance in the first
        place, so we'd like to reduce overhead as much as possible.  Hence,
        messages passed will be passed in fixed-length binary fields, rather
        than in ASCII-delimited messages.
      </p>

      <p>
        RFTP has two types of messages: 
      </p>

      <ul>
        <li>
          <strong>Control message</strong> — initiates and terminates
          a file transfer session.
        </li>
        <li>
          <strong>Data message</strong> — transfers a chunk of file data
        </li>
      </ul>

      <p>
        UDP is capable of transporting up to 65527 bytes of
        application-layer data in its payload (if you don't know why,
        you should figure this out — see the midterm).  However,
        Ethernet — a very common link-layer protocol —
        allows only 1500 bytes of data in each of its frames.  Indeed, we
        say that Ethernet has a <em>Maximum Transmission Unit (MTU)</em> of
        1500 bytes.
      </p>

      <p>
        If we try to send larger amounts of data, the data has to be
        <em>fragmented</em> — broken up into multiple frames — and
        sent.  At the receiving end, it then has to be reassembled.  This
        process of fragmentation and reassembly can decrease performance.
        Hence, we will limit the amount of data we send in each
        application-layer message to what can be contained in a single
        Ethernet frame, so that no fragmentation is needed.
      </p>

      <p>
        To compute this, we begin with the MTU of Ethernet: 1500 bytes.  From
        that, we subtract the size of the IP header in the network layer: 20
        bytes.  Next, we subtract the size of the UDP header in the transport
        layer: 8 bytes.  Doing the math, this gives us a Maximum Segment Size (MSS) of:
      </p>

      <p>
        <code>MSS = 1500 bytes (Ethernet MTU) - 20 bytes (IP header) - 8 bytes (UDP header) = 1472 bytes</code>
      </p>

      <p>
        Hence, regardless of the type of RFTP message we're sending —
        control or data — we will limit the size of each message sent to
        1472 bytes.
      </p>

      <h5 style="margin-top: 20px">RFTP Control Message</h5>

      <p>A control message consists of the following fields (click to enlarge):</p>

      <a href="/cs3357/assignments/asn2/files/cs3357-fall2014-asn2-msg-control.png">
        <img class="thumb" src="/cs3357/assignments/asn2/files/cs3357-fall2014-asn2-msg-control.png">
      </a>

      <div class="mb20"></div>

      <p>Descriptions of the fields are as follows (all fields are <strong>unsigned</strong>):</p>

      <div class="mb30"></div>

      <table class="table table-bordered table-striped table-hover">
        <thead>
          <tr>
            <th>Field</th>
            <th>Size</th>
            <th>Description</th>
          </tr>
        </thead>
        <tfoot>
          <tr>
            <td></td>
            <td><strong>1472 bytes total</strong></td>
            <td></td>
          </tr>
        </tfoot>
        <tbody>
          <tr>
            <td><code>Type</code></td>
            <td>8 bits</td>
            <td>
              Identifies the message type.  A control message always has
              <code>type</code> equal to <code>1</code> (initiation) or
              <code>2</code> (termination).
            </td>
          </tr>
          <tr>
            <td><code>ACK</code></td>
            <td>8 bits</td>
            <td>
              Identifies whether the message is being sent (<code>0</code>) or
              acknowledged (<code>1</code>).
            </td>
          </tr>
          <tr>
            <td><code>Sequence Number</code></td>
            <td>16 bits</td>
            <td>
              Sequence number of the message.  RFTP only requires a 1-bit
              sequence number (<code>0</code> and <code>1</code>), but this
              field is 16 bits to allow for higher sequence numbers to be used
              in future versions of the protocol.
            </td>
          </tr>
          <tr>
            <td><code>File Size</code></td>
            <td>32 bits</td>
            <td>Size (in bytes) of the file to be transferred.  <em>What is the maximum
                size of a file that can be transferred with RFTP?</em></td>
          </tr>
          <tr>
            <td><code>Filename Length</code></td>
            <td>32 bits</td>
            <td>
              Number of characters in the <code>Filename</code> field (since
              it is not <code>NULL</code>-terminated).  This field does not need anywhere
              near 32 bits, but uses a full 32 bits for the purpose of memory
              alignment.
            </td>
          </tr>
          <tr>
            <td><code>Filename</code></td>
            <td>Variable (up to 1460 bytes)</td>
            <td>
              Name of the file to be transferred.  This field should NOT
              include the <code>NULL</code> terminator.  A control message has
              12 bytes of headers, followed by a variable-length filename.
              This means the filename can be as many as <code>1472 - 12 =
              1460</code> bytes in length.
            </td>
          </tr>
        </tbody>
      </table>

      <div class="mb30"></div>

      <p>The control message is used in several ways:</p>

      <ul>
        <li>
          When the client wants to initiate a transfer, it sends a
          type <code>1</code> control message (<em>initiation
          message</em>) to the server.  The sequence number of
          this initial message is always <code>0</code>.
        </li>
        <li>
          To ACK the message, the server responds with a type <code>1</code>
          control message of its own, setting the <code>ACK</code> field to
          <code>1</code> and the <code>Sequence Number</code> field to
          <code>0</code>.  The rest of the fields are left empty.
        </li>
        <li>
          When the client is done transferring data and wants to
          terminate the connection, it sends a type <code>2</code>
          control message (<em>termination message</em>) to the server
          with the next expected sequence number in the <code>Sequence
          Number</code> field.
        </li> 
        <li>
          To ACK the termination message, the server responds with a type
          <code>2</code> control message, setting the <code>ACK</code> field
          <code>1</code> and the <code>Sequence Number</code> field to the
          sequence number of the received termination message.
        </li>
      </ul>

      <h5 style="margin-top: 20px">RFTP Data Message</h5>

      <p>A data message consists of the following fields:</p>

      <a href="/cs3357/assignments/asn2/files/cs3357-fall2014-asn2-msg-data.png">
        <img class="thumb" src="/cs3357/assignments/asn2/files/cs3357-fall2014-asn2-msg-data.png">
      </a>

      <div class="mb20"></div>

      <p>Descriptions of the fields are as follows:</p>

      <div class="mb30"></div>

      <table class="table table-bordered table-striped table-hover">
        <thead>
          <tr>
            <th>Field</th>
            <th>Size</th>
            <th>Description</th>
          </tr>
        </thead>
        <tfoot>
          <tr>
            <td></td>
            <td><strong>1472 bytes total</strong></td>
            <td></td>
          </tr>
        </tfoot>
        <tbody>
          <tr>
            <td><code>Type</code></td>
            <td>8 bits</td>
            <td>
              Identifies the message type.  A data message always has
              <code>type</code> equal to <code>3</code>.
            </td>
          </tr>
          <tr>
            <td><code>ACK</code></td>
            <td>8 bits</td>
            <td>
              Identifies whether the message is being sent (<code>0</code>) or
              acknowledged (<code>1</code>).
            </td>
          </tr>
          <tr>
            <td><code>Sequence Number</code></td>
            <td>16 bits</td>
            <td>
              Sequence number of the message.  RFTP only requires a 1-bit
              sequence number (<code>0</code> and <code>1</code>), but this
              field is 16 bits to allow for higher sequence numbers to be used
              in future versions of the protocol.
            </td>
          </tr>
          <tr>
            <td><code>Data Length</code></td>
            <td>32 bits</td>
            <td>
              The number of bytes of data in the <code>Data</code> field.
              This field does not need anywhere near 32 bits, but uses a full
              32 bits for the purpose of memory alignment.
            </td>
          </tr>
          <tr>
            <td><code>Data</code></td>
            <td>Variable (up to 1464 bytes)</td>
            <td>
              A sequence of file data bytes.  A data message has 8 bytes of
              headers, followed by a variable-length data field.  This means
              that up to <code>1472 - 8 = 1464</code> bytes of data can be
              transferred in a data message.
            </td>
          </tr>
        </tbody>
      </table>

      <div class="mb30"></div>

      <p>The data message is used in the following ways:</p>

      <ul>
        <li>
          When the client wants to send a chunk of file data, it sends it in a
          data message to the server.   Since the initial control message has a
          sequence number of <code>0</code>, the first data message will have a
          sequence number of <code>1</code>.
        </li>
        <li>
          To ACK the message, the server responds with a data message of its
          own, setting the <code>ACK</code> field to <code>1</code> and the
          <code>Sequence Number</code> field to the sequence number of the
          message received.  The rest of the fields are left empty.
        </li>
      </ul>

      <p>
      </p>

      <div class="mb20"></div>

      <h4>The Client</h4>

      <p>
        The client implements the sender side of RDT 3.0 to transfer a file
        reliably over UDP to the server.
      </p>

      <h5>Command-Line Parameters</h5>

      <p>
        The synopsis of the client is as follows:
      </p>

      <p>
        <code>rftp [OPTIONS...] [SERVER] [FILENAME]</code>
      </p>

      <ul>
        <li><code>SERVER</code> is the hostname or IP address of the server</li>
        <li><code>FILENAME</code> is the name of the file to transfer</li>
      </ul>

      <p>
        Both <code>SERVER</code> and <code>FILENAME</code> are required
        non-option arguments.  If either are missing, an error should be
        printed and the program should exit.
      </p>

      <p>
        The client must use the <code>getopt_long</code> function (see Lab 2)
        to parse the command line arguments.  In addition to the non-option
        arguments above, your program must support the following options.
        Observe that each option has a default value that should be used if
        the option is not specified on the command line.
      </p>

      <table class="table">
        <thead>
          <tr>
            <th>Parameter</th>
            <th>Description</th>
            <th>Example</th>
            <th>Default</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><code>-v</code> / <code>--verbose</code></td>
            <td>Enable verbose output (see description later)</td>
            <td><code>-v</code></td>
            <td><em>Non-verbose output</em></td>
          </tr><tr>
            <td><code>-t</code> / <code>--timeout</code></td>
            <td>The number of <strong>milliseconds</strong> to wait before retransmitting a message</td>
            <td><code>-t 1000</code></td>
            <td><code>50</code></td>
          </tr>
          <tr>
            <td><code>-p</code> / <code>--port</code></td>
            <td>The port on which the server is listening</td>
            <td><code>-p 9999</code></td>
            <td><code>5000</code></td>
          </tr>
        </tbody>
      </table>


      <h5>Client FSM</h5>

      <p>
        The finite state machine for the client is based on the RDT 3.0 sender (figure 3.15 in the
        textbook, on page 215).  Click the image to enlarge it.
      </p>

      <a href="/cs3357/assignments/asn2/files/cs3357-fall2014-asn2-client-fsm.png">
        <img class="thumb" src="/cs3357/assignments/asn2/files/cs3357-fall2014-asn2-client-fsm.png">
      </a>

      <div class="mb10"></div>

      <p>
        Note: we are presenting the client's logic in a FSM to help you understand it.
        You do <em>not</em> actually need to implement a FSM in code (it would add 
        unnecessary complexity to do so).  Just use the FSM to guide your program logic.
      </p>

      <h5>Client Output</h5>

      <p>
        If verbose output has <em>not</em> been enabled, the client should regularly display the
        following information in a neat and orderly manner:
      </p>
      
      <ul>
        <li>Number of bytes successfully transferred
        </li><li>Total number of bytes</li>
        <li>Percent complete</li>
      </ul>

      <p>
        <strong>Note the use of the term <em>regularly</em> above.</strong>
        This does not mean report an update after every acknowledgement.
        Transferring a 4 GB file and producing output on every 1464 byte chunk
        would make for extremely messy output.  A good idea might be to choose
        a certain data size <code>X</code> and to product output each time
        <code>X</code> bytes have been successfully transferred and
        acknowledged.  Use your discretion.  Make your output neat, but keep
        your program responsive and informative.
      </p>
      
      <p>
        If verbose output <em>has</em> been enabled, the client should display, upon every
        message sent (this information should be in one line — do not print 3 lines for every message, please):
      </p>

      <ul>
        <li>The type of message (do <strong>not</strong> print <code>Type 1</code> — assume the user doesn't know anything about this protocol)</li>
        <li>The sequence number of the message</li>
        <li>The amount of data in the message (if applicable)
      </li></ul>

      <p>
        In verbose mode, upon every ACK received, the client should display (in one line):
      </p>

      <ul>
        <li>The type of ACK</li>
        <li>The sequence number of the ACK</li>
      </ul>

      <p>
        Finally, verbose mode should display the same output as non-verbose mode in regular intervals.
      </p>

      <h4>The Server</h4>

      <p>
        The server implements the receiver side of RDT 2.2 to receive a file
        reliably over UDP from the client.
      </p>

      <h5>Command-Line Parameters</h5>

      <p>
        The synopsis of the server is as follows:
      </p>

      <p>
        <code>rftpd [OPTIONS...] [OUTPUTDIR]</code>
      </p>

      <ul>
        <li>
          <code>OUTPUTDIR</code> — the directory into which transferred
          files will be saved.  This is a required non-option argument.  If it
          is missing, an error should be printed and the program should exit.
        </li>
      </ul>

      <p>
        The server must use the <code>getopt_long</code> function (see Lab 2)
        to parse the command line arguments.  In addition to the non-option
        argument above, your program must support the following options.
        Observe that each option has a default value that should be used if
        the option is not specified on the command line.
      </p>

      <table class="table">
        <thead>
          <tr>
            <th>Parameter</th>
            <th>Description</th>
            <th>Example</th>
            <th>Default</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><code>-v</code> / <code>--verbose</code></td>
            <td>Enable verbose output (see description later)</td>
            <td><code>-v</code></td>
            <td><em>Non-verbose output</em></td>
          </tr><tr>
            <td><code>-t</code> / <code>--timewait</code></td>
            <td>The number of <strong>seconds</strong> to spend in the <code>TIME_WAIT</code> state before exiting</td>
            <td><code>-t 20</code></td>
            <td><code>30</code></td>
          </tr>
          <tr>
            <td><code>-p</code> / <code>--port</code></td>
            <td>The port on which to listen</td>
            <td><code>-p 9999</code></td>
            <td><code>5000</code></td>
          </tr>
        </tbody>
      </table>

      <h5>Server FSM</h5>

      <p>
        The finite state machine for the server is based on the RDT 2.2 sender (figure 3.14 in the
        textbook, on page 214).  Click the image to enlarge it.
      </p>


      <a href="/cs3357/assignments/asn2/files/cs3357-fall2014-asn2-server-fsm.png">
        <img class="thumb" src="/cs3357/assignments/asn2/files/cs3357-fall2014-asn2-server-fsm.png">
      </a>

      <h5>Server Output</h5>

      <p>
        The same requirements apply for the server output as with the
        client output.  The user should be regularly updated on the
        progress of the transfer.  If verbose mode is specified, the
        program should print information on each message sent and
        received (see the <strong>Client Output</strong> section for
        more information).
      </p>

      <h5>The <code>TIME_WAIT</code> State</h5>

      <p>
        To understand the need for the <code>TIME_WAIT</code> state, consider
        what happens if we ACK a type 2 control message, but the ACK gets lost.
        What will the client do?
      </p>

      <div class="mb20"></div>

      <h4>Hints</h4>

      <ul>
        <li>
          To test your program, you can (and should) <a href="/cs3357/assignments/asn2/netem/">simulate a noisy channel</a>.
        </li>
        <li>
          Do lab 4 (coming soon) for information on UDP socket programming.  If you'd like to
          get started in the meantime, see <a href="http://beej.us/guide/bgnet/">Beej's guide</a>.
        </li>
        <li>
          Do lab 5 (coming soon) for information on sniffing your client-server communications
          with Wireshark.  This will help you in debugging the communication between your 
          client and server, particularly since RFTP is a binary protocol.
        </li>
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
        <li>
          Friendly tip: a pointer to a struct can be cast to a pointer to another
          type of struct, if the two struct types are of the same size.
          <i class="fa fa-smile-o"></i>
        </li>
        <li>
          <code>fopen</code>, <code>fread</code>, <code>fwrite</code>, and <code>fclose</code>
          could be useful.  See the man pages!
        </li>
        <li>
          You do <em>not</em> need to (and probably <em>should not</em>) use
          signals to implement a timer in this program.  See the <code>poll</code>
          function.
        </li>
        <li>Start soon.</li>
      </ul>

      <div class="mb20"></div>

      <h4>General Requirements</h4>

      <ul>
        <li>
          It must be possible to build both the client and server at the same
          time, simply by typing <code>make</code>; this implies that you'll
          need to create a basic <code>Makefile</code>.
        </li>
        <li>
          The <code>Makefile</code> should build two executables:
          <code>rftp</code> and <code>rftpd</code> (the RFTP 
          <em>daemon</em>).   Make sure you adhere to these naming conventions.
          We have one TA marking 50+ assignments, and it slows down the whole
          process when everyone uses a different name for their executables.  It
          also prevents us from running automated tests.
        </li>
        <li>The client and server must run in the CS 3357 virtual machine.</li>
        <li>Compile your code with <code>-Wall</code> — we will.</li>
        <ul><li>Repeat this mantra: warnings are errors.  Warnings are errors.  Warnings are errors.</li></ul>
        <li>Check your code for memory leaks using <code>valgrind</code> — we will.</li>
        <ul>
          <li>Install it with <code>sudo apt-get install valgrind</code></li>
          <li>Run it with <code>valgrind ./program [args]</code></li>
        </ul>
        <li>Files and sockets opened must be closed properly prior to exiting a program.</li>
        <li>Modularize your code.  Your mark will suffer if you hand in all client code in one file, and all server code in another.  Similarly, large functions should be modularized and broken up into smaller, tightly-focused functions.  Place related functions in a file together.  Where possible, share code between client and server.</li>
        <li>Both the client and server must be written in standard C (to be exact, in C90 with GNU extensions, which is the default mode that <code>gcc</code> provides when you don't specify a standard).  You may not use C99, C++, Objective C, or any other dialects, extensions, or languages.</li>
        <li>Yes, you do need to comment your code.  Sorry.  It sucks, but it's necessary.
          <ul>
            <li>Your code should contain a reasonable amount of inline comments to allow someone to follow your algorithms.</li>
            <li>Variable declarations should be commented, describing the purpose of the variables.</li>
            <li>Each function must have a header comment, describing the function, its parameters, and its return value.</li>
            <li>Each file (both <code>.c</code> and <code>.h</code> should contain a header comment at the top of the file including, at a minimum: the filename, a description of the file, the course code, the assignment number, your name, and your email address.  For instance,

            <pre><code>/********************************************************************************
 * rftp.c
 * 
 * Computer Science 3357a
 * Assignment 2
 *
 * Author: Jeff Shantz <jeff@csd.uwo.ca>
 * 
 * Brief description of the file goes here.
*******************************************************************************/</jeff@csd.uwo.ca></code></pre>
             </li>
           </ul>
         </li>

         <li>Good coding practices should be followed, such as declaring constants (<code>#define</code>) instead of using magic numbers; adhering to good variable and function naming practices; etc.  Your functions and files should be of a reasonable size.  If your whole program is implemented in one function (or even one file), or if we find 50-line functions in your code, that's going to be affect your style mark.  Strive for modularity.</li>

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
                  <li>The final commit representing your submission must be tagged <code>asn2</code> — <strong>don't forget to push the tag to GitHub.  Your assignment is not submitted until that tag is pushed to GitHub.</strong></li>
                  <li>The assignment should reside within a directory <code>asn2</code> in the <em>root</em> of your GitHub repository.</li>
                  <li>Your <code>asn2</code> directory should contain only <code>.c</code> files, <code>.h</code> files, and a <code>Makefile</code>.  If you like, you may also include a file named <code>README</code> in your <code>asn2</code> directory in the event that you have something you wish to pass along to the TA.</li>
                  <li>To organize your code better, you may arrange your code into subdirectories, but your <code>Makefile</code> should exist in the <code>asn2</code> directory, and it should produce the executables <code>rftp</code> and <code>rftpd</code> in the <code>asn2</code> directory itself (not in a subdirectory).</li>
                  <li>Notice that the directory name and tag are <code>asn2</code> — <em>not</em> <code>Assignment2</code>, <code>Asn2</code>, <code>Asmt2</code>, or anything else.</li>
                </ul>

                <h4>FAQ</h4>

                <hr>

                <h5>
                  <i class="fa fa-question-circle"></i>
                  Question 1<br>
                  <small style="padding-left: 17px">November 04, 2014 at 20:35</small>
                </h5>

                <hr>

                <blockquote>

                  <p>
                    <i class="fa fa-quote-left"></i> 
                    How do we use <code>getopt_long</code> to get the server and filename? I'm not sure how to go about it without using flags.
                  </p>
  
                </blockquote>

                <hr>

                <h5>
                  <i class="fa fa-bullhorn"></i>
                  Answer 1
                </h5>

                <hr>

                <div class="answer">
                  <p>
                    Lab 2 shows how to handle this using <code>optind</code>.
                  </p>
                </div>

                <hr>

                <h5>
                  <i class="fa fa-question-circle"></i>
                  Question 2<br>
                  <small style="padding-left: 17px">November 04, 2014 at 20:35</small>
                </h5>

                <hr>

                <blockquote>

                  <p>
                    <i class="fa fa-quote-left"></i> 
                    How would you like the server to handle duplicate filenames?  For example, if the server already has <code>a.txt</code> and we send it a file of the same name, what should it do?  Overwrite the file?  Print an error message?
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
                    The server should just overwrite the file, in the case of a duplicate filename.
                  </p>
                </div>

                <hr>

                <h5>
                  <i class="fa fa-question-circle"></i>
                  Question 3<br>
                  <small style="padding-left: 17px">November 04, 2014 at 20:35</small>
                </h5>

                <hr>

                <blockquote>

                  <p>
                    <i class="fa fa-quote-left"></i> 
                    In the assignment spec, it says we're implementing RDT 3.0, but in the server section, it refers to RDT 2.2 a few times. I'm assuming that's a typo?
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
                    It's actually not a typo.  There is no RDT 3.0 receiver.  The textbook notes that the RDT 2.2 receiver can be used unaltered for version 3.0 of the protocol.
                  </p>

                  <p>
                    In any event, we're really implementing a <em>variant</em> of the RDT protocol, so use the algorithms from the finite state machines in the assignment spec, rather than using those from the textbook.
                  </p>
                </div>

                <hr>

                <h5>
                  <i class="fa fa-question-circle"></i>
                  Question 4<br>
                  <small style="padding-left: 17px">November 04, 2014 at 20:35</small>
                </h5>

                <hr>

                <blockquote>

                  <p>
                    <i class="fa fa-quote-left"></i> 
                    It is bothering me that we have an ACK field in the message types. Why can't we just create ACK messages that are only used by the receiver side?
                  </p>
  
                </blockquote>

                <hr>

                <h5>
                  <i class="fa fa-bullhorn"></i>
                  Answer 4
                </h5>

                <hr>

                <div class="answer">
                  <p>
                    We could, but the protocol was given in the assignment spec, and we're going to stick with that.  This is not uncommon.  DNS, as we saw, uses the same message format for its requests and replies.
                  </p>
                  <p>
                    Also, consider how sharing a message format simplifies your coding:
                  </p>
                  <ol>
                    <li>You don't have to implement another message type</li>
                    <li>You can reuse the same message object that you receive.  Just set its ACK field to <code>1</code> and send it back (albeit, without the data — just send the Type, Ack, and Sequence number fields without the rest of the message).
                  </li></ol>
                </div>

                <hr>

                <h4>Bonus (up to 25%)</h4>

                <p>
                  Implement the standard assignment, as described above, and then implement either
                  Go-Back-N or Selective Repeat (not both — don't spend all your time on CS 3357).
                </p>

                <p>
                  If you choose to implement Go-Back-N, then the user should be able to specify the
                  <code>--gbn N</code> option on the command line to enable Go-Back-N mode, where
                  <code>N</code> is the window size.
                </p>

                <p>
                  If you choose to implement Selective Repeat, then the user should be able to specify
                  the <code>--sr N</code> option on the command line to enable Selective Repeat mode,
                  where <code>N</code> is the window size.
                </p>

                <p>
                  If neither <code>--gbn</code> nor <code>--sr</code> are specified, then the program
                  should default to the Stop-and-Wait protocol.
                </p>

                <p>Your output should indicate which mode is currently in use in both the client and
                server.  If GBN or SR mode are enabled, the output should also indicate details useful
                to help the user understand what's going on (e.g. current window size, next sequence
                number, etc.)</p>

                <p><strong>You must have the base functionality complete before attempting the bonus.
                  No bonus marks will be awarded if your Stop-and-Wait protocol does not work.</strong></p>

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