*** Settings ***
Library     REST    https://jsonplaceholder.typicode.com
*** Variables ***
${json}     {"id":11, "name": "Gil Alexander"}
&{dict}     name=Julie Langford
*** Test Cases ***
GET an existing user, notice how the schema gets more accurate
    [tags]          a
    GET            /users/1
    #Output schema   response body
    Object          response body
    Object	response body	required=["id", "name"]
    Integer        response body id        1
    String          response body name      Leanne Graham


GET users use JsonPath
    ${response}=    GET             /users?_limit=5
    Array           response body
    Integer         $[0].id                 1
    String          $[0]..lat               -37.3159
    Integer         $..id                   maximum=5
    #log to console  ${response}
    [Teardown]      Output                  $[*].email
POST with valid params to create a new user
    [tags]          b
    ${response}=    POST            /users                  ${json}
    Integer         response status         201
    [Teardown]      Output      response body       ${OUTPUTDIR}/new_user.demo.json
   # log to console      ${response}

PUT with valid params to update the existing user
    #${body}=    create dictionary   id=3
    ${response}=    PUT             /users/2                {"isCoding":true}       #data=${body}
    Boolean         response body isCoding      true
    PUT             /users/2                {"sleep":null}
    Null           response body sleep
    ${res1}=     PUT             /users/2                {"pockets":"","money":0.05}
    String          response body pockets   ${EMPTY}
    Number          response body money     0.05
    Missing         response body moving            #Khẳng định trường không tồn tại
    #log to console      ${res1}

PATCH with valid params
    &{res} =     GET     /users/3
    String  $.name          Clementine Bauch
    PATCH      /users/4     {"name":"${res.body['name']}"}
    String  $.name          Clementine Bauch
    PATCH       /users/5        ${dict}
    String      $.name          ${dict.name}
    #log to console      ${res.body}

DELETE the existing successfully,save history of all requests
    [tags]      c
    DELETE      /users/6
    Integer     response status     200     202     204
    REST instances      ${OUTPUTDIR}/all.demo.json
