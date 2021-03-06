jQuery ->
  oTable = $('.shaintable').DataTable({
    "dom": 'lBfrtip',
    "pagingType": "simple_numbers"
    ,"oLanguage":{
      "sUrl": "../../assets/resource/dataTable_"+$('#language').text()+".txt"
    }
    ,
    "aoColumnDefs": [ 
      { "bSortable": false, "aTargets": [ 10,11 ]},
      {
        "targets": [10,11],
        "width": '5%'
      }
    ],
    "oSearch": {"sSearch": queryParameters().search},

    "buttons": [{
                "extend":    'copyHtml5',
                "text":      '<i class="fa fa-files-o"></i>',
                "titleAttr": 'Copy'
            },
            {
                "extend":    'excelHtml5',
                "text":      '<i class="fa fa-file-excel-o"></i>',
                "titleAttr": 'Excel'
            },
            {
                "extend":    'csvHtml5',
                "text":      '<i class="fa fa-file-text-o"></i>',
                "titleAttr": 'CSV'
            },
            {
              "extend": 'selectAll',
              "action": ( e, dt, node, config ) ->
                oTable.$('tr').addClass('selected')
                oTable.$('tr').addClass('success')
                selects = oTable.rows('tr.selected').data()
                if selects.length == 0
                  $("#edit_shain").attr("disabled", true);
                  $("#destroy_shain").attr("disabled", true);
                else
                  $("#destroy_shain").attr("disabled", false);
                  if selects.length == 1
                    $("#edit_shain").attr("disabled", false);
                  else
                    $("#edit_shain").attr("disabled", true);
                $(".buttons-select-none").removeClass('disabled')




            },
            {
              "extend": 'selectNone',
              "action": ( e, dt, node, config ) ->
                oTable.$('tr').removeClass('selected')
                oTable.$('tr').removeClass('success')
                selects = oTable.rows('tr.selected').data()
                if selects.length == 0
                  $("#edit_shain").attr("disabled", true);
                  $("#destroy_shain").attr("disabled", true);
                else
                  $("#destroy_shain").attr("disabled", false);
                  if selects.length == 1
                    $("#edit_shain").attr("disabled", false);
                  else
                    $("#edit_shain").attr("disabled", true);
                $(".buttons-select-none").addClass('disabled')
            }

            ]
  })

  $("#edit_shain").attr("disabled", true);
  $("#destroy_shain").attr("disabled", true);


  $(document).bind('ajaxError', 'form#new_shain', (event, jqxhr, settings, exception) ->
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
  )

  $.fn.render_form_errors = (errors) ->
    $form = this;
    this.clear_previous_errors();
    model = this.data('model');


    $.each(errors, (field, messages) ->
      $input = $('input[name="' + model + '[' + field + ']"]');
      $input.closest('.form-group').addClass('has-error').find('.help-block').html( messages.join(' & ') );
    );


  $.fn.clear_previous_errors = () ->
    $('.form-group.has-error', this).each( () ->
      $('.help-block', $(this)).html('');
      $(this).removeClass('has-error');
    );


  $('.shaintable').on( 'click', 'tr',  () ->
    d = oTable.row(this).data()
    if d != undefined
      if $(this).hasClass('selected')
        $(this).removeClass('selected')
        $(this).removeClass('success')
        # $("#edit_shain").attr("disabled", true);
        # $("#destroy_shain").attr("disabled", true);
      else
        # oTable.$('tr.selected').removeClass('selected')
        # oTable.$('tr.success').removeClass('success')
        $(this).addClass('selected')
        $(this).addClass('success')       
        #$("#edit_shain").attr("disabled", true);
        # $("#edit_shain").attr("disabled", false);
        # $("#destroy_shain").attr("disabled", false);
    selects = oTable.rows('tr.selected').data()
    if selects.length == 0
      $("#edit_shain").attr("disabled", true);
      $("#destroy_shain").attr("disabled", true);
      $(".buttons-select-none").addClass('disabled')
    else
      $("#destroy_shain").attr("disabled", false);
      $(".buttons-select-none").removeClass('disabled')
      if selects.length == 1
        $("#edit_shain").attr("disabled", false);
      else
        $("#edit_shain").attr("disabled", true);

  )

  $('#destroy_shain').click () ->
    shains = oTable.rows('tr.selected').data()
    shainIds = new Array();
    if shains.length == 0
      swal($('#message_confirm_select').text())
    else

      swal({
        title: $('#message_confirm_delete').text(),
        text: "",
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: "OK",
        cancelButtonText: "キャンセル",
        closeOnConfirm: false,
        closeOnCancel: false
      }).then(() ->
        len = shains.length
        for i in [0...len]
          shainIds[i] = shains[i][1]

        $.ajax({
          url: '/shainmasters/multi_delete',
          data:{
            focus_field: 'shain_削除する',
            shains: shainIds
          },

          type: "POST",

          success: (data) ->
            swal("削除されました!", "", "success");
            if data.destroy_success != null
              console.log("getAjax destroy_success:"+ data.destroy_success)
              oTable.rows('tr.selected').remove().draw()
            else
              console.log("getAjax destroy_success:"+ data.destroy_success)


          failure: () ->
            console.log("shain_削除する keydown Unsuccessful")

        })
        $("#edit_shain").attr("disabled", true);
        $("#destroy_shain").attr("disabled", true);

      ,(dismiss) ->
        if dismiss == 'cancel'

          selects = oTable.rows('tr.selected').data()
          if selects.length == 0
            $("#edit_shain").attr("disabled", true);
            $("#destroy_shain").attr("disabled", true);
          else
            $("#destroy_shain").attr("disabled", false);
            if selects.length == 1
              $("#edit_shain").attr("disabled", false);
            else
              $("#edit_shain").attr("disabled", true);
      );
  $('#edit_shain').click ->      
    new_address = oTable.row('tr.selected').data()[10].split("\"")[1]    
    if new_address == undefined
      swal("行を選択してください。")
    else            
      window.location = new_address