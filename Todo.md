TODO:
Fare prova:
  1 worker molti miner 
  OPPURE 
  1 worker per ogni miner? 
  Quale va piu' veloce?

Preparare Server

client>  server/causes/ >
client>  server/miner/  > pool, worker_user, worker_pass

get "/server/miner" do
  content_type :json
  {
    pool: "stratum+tcp://dgc.hash.so:3341",
    worker_user: "Virtuoid.1",
    worker_pass: "1"
  }
end


 "-o stratum+tcp://dgc.hash.so:3341 -u Virtuoid.1 -p 1"



























# EptiMecha
### Eptisa Mechanize powered JRuby Profligacy app


### Prerequisites

jruby+jre: <jruby.org/downloads>

### Install

    gem i warbler profligacy mechanize ftools zip

use jgem if gem is not available
 
### Run

    ruby bin/eptimecha

### Develop

create jar

    rm eptimecha.jar; warble

launch 

    java -jar .\eptimecha.jar

see bin/eptimecha, eptimecha.rb, core.rb and ui.rb

enjoy!

notes: If you don't have java in your path on windows try referencing the java executable directly like:

    C:\jruby-1.7.3\jre\bin\java.exe -jar .\eptimecha.jar
    
dev oneliners

    rm eptimecha.jar; warble; java -jar eptimecha.jar 

    rm eptimecha.jar && warble && java -jar eptimecha.jar 

    c:\jruby-1.7.3\bin\jruby.exe bin\eptidl

### TODO:

riders
  mul- serial number
  print pdf/rtf
    rider
    cover letter

  attached documents
  external monitoring / evaluation / audits
    external monitoring reports
    reference

