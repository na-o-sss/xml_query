query_entity = ->
  $('#query-box input')

output_entity = ->
  $('#output-box textarea')

xml_entity = ->
  $('#xml-box textarea')

read_xml = ->
  try
    xml = $.parseXML( xml_entity().val() )
  catch e
    invalid_xml()
    throw e
  valid_xml()
  xml

format_xml = (xml) ->
  args = {source: xml, mode: 'beauty', insize: 2, force_indent: false}
  markup_beauty(args)

serializer = new XMLSerializer()

xml_to_string = ($xml) ->
  format_xml serializer.serializeToString($xml)

no_data_found = ->
  "not found"

single_node_found = ($xml) ->
  xml_to_string($xml.get(0))

distinct_button = ->
  $('#distinct input')

distinct_checked = ->
  distinct_button().is(':checked')

multi_nodes_found = ($xml) ->
  nodes = []
  for entity in $xml
    nodes.push xml_to_string(entity)

  nodes.join("\n")

execute_query = ->
  try
    $xml = $( read_xml() )
  catch e
    output_entity().val('XML format is invalid')
    return
  query = query_entity().val()

  try
    found = $xml.find(query)
  catch e
    invalid_query()
    output_entity().val('invalid query')
    return
  valid_query()

  if distinct_checked()
    found = jQuery.unique(found)

  switch found.size()
    when 0 then result = no_data_found()
    when 1 then result = single_node_found(found)
    else result = multi_nodes_found(found)

  output_entity().val result  

invalid_xml = ->
  $('#xml-box .glyphicon').removeClass('hidden')

valid_xml = ->
  $('#xml-box .glyphicon').addClass('hidden')

invalid_query = ->
  $('#query-box .glyphicon').removeClass('hidden')

valid_query = ->
  $('#query-box .glyphicon').addClass('hidden')

jQuery ->
  execute_query()

  $('#title').click ->
    window.open('http://api.jquery.com/category/selectors/')

  query_entity().keypress (event) ->
    if event.which == 13
      execute_query()

  xml_entity().change ->
    try
      xml = read_xml()
    catch e
      return
    args = {source: xml, mode: 'beauty', insize: 2, force_indent: false}
    indented_xml = markup_beauty(args)
    xml_entity().val 

  distinct_button().change ->
    execute_query()