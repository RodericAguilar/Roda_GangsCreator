window.addEventListener("message", function(event) {
    var v = event.data
    var point = null
    switch (v.action) {
        case 'openUI': 
            $('.Container').show(500)
            $('.menu').show(500)
        break;


        case 'openCurrent': 
            $('.GangManager').show(500)
        break;

        case 'recluteNewMember': 
            $('.contPlayersNews').append(`
                <div class="PlayerInfoxD ${v.playerId}-click" id="${v.playerId}">
                    <h1 class="${v.playerId}-name" id="${v.label}">${v.label} [${v.playerId}]</h1>
                </div>
            `)
            $('.ReclutMembers').show(500)

            $(`.${v.playerId}-click`).click(function () {
                let nick = $(`.${v.playerId}-name`).attr('id')
                $('#putitainvisible3').attr('class', v.playerId)
                $('#putitainvisible4').attr('class', nick)
                $('#updateUserNewName').text(`Reclute ${nick}`)	
                $('.ModalForNewMembers').show(500)
            })
        break;


        case 'openInvitation': 
                $('.putitoInvisible').attr('id', v.src)
                $('.putitoInvisible2').attr('id', v.target)
                $('.putitoInvisible3').attr('id', v.gang)
                $('.putitoInvisible4').attr('id', v.range)
                $('.ModalAcceptOrNot h1').text(`You got an invite from ${v.label}`)
                $('.ModalAcceptOrNot').show(500)
        break;


        case 'openIdentity': 
            let infor = v.datos
            $('#nameid').text(infor.firstname)
            $('#apellidoid').text(infor.lastname)
            $('#sexoid').text(infor.sex)
            $('.idCard').show()
            const pictureURL = `https://nui-img/${v.foto}/${v.foto}`;
            $('.FotoIdentity img').attr('src', pictureURL)
         
        break;

        case 'openGangMenu': 
            let actions = v.actions
            let drag
            let handcuff
            let search 
            let request
            $('.gangNameXD').text(v.label)
            $('.containerOptions').append(`
                <div class="OptionxD" id="drag">
                <h1>Drag</h1>
                </div>
                <div class="OptionxD" id="requestP">
                <h1>Get Identity</h1>
                </div>
                <div class="OptionxD" id="search">
                <h1>Search</h1>
                </div>
                <div class="OptionxD" id="esposar">
                <h1>Handcuff/Uncuff</h1>
                </div>
            `)

            $('#esposar').click(function(){
                $.post('https://Roda_GangsCreator/handcuff')
            })

            $('#drag').click(function(){
                $.post('https://Roda_GangsCreator/drag')
            })

            $('#search').click(function(){
                $.post('https://Roda_GangsCreator/search')
            })

            
            $('#requestP').click(function(){
                $.post('https://Roda_GangsCreator/GetIdentity')
            })

            if (actions.drag == false) {
                $('#drag').hide()
            } else {
                $('#drag').show()
            }

            if (actions.handcuff == false) {
                $('#esposar').hide()
            } else {
                $('#esposar').show()
            }

            if (actions.search == false) {
                $('#search').hide()
            } else {
                $('#search').show()
            }

            if (actions.request == false) {
                $('#requestP').hide()
            } else {
                $('#requestP').show()
            }
            
            $('.menuGangsters').show(500)
        break;

        case 'showGang': 
            $('.ContainerGangsSearch').append(`
            <div class="GangInfos">
            <p>${v.label} (${v.gang})</p>
                <center>
                <img id="${v.gang}" src="${v.logo}" alt="">
                </center>
            </div>
            `)
            $(`#${v.gang}`).click(function(){
                $('#putitainvisible').attr('class', v.gang)
                $('.setText').text(`Manage ${v.label}`)
                $('.setText').attr('id', v.label)
                $('.ContainerGangsSearch').empty()
                $('.centerSearch').hide()
                $('.ContainerOfGangs').show()
            })
        break;


        case 'openClothes': 
            $('.ArmarioContainer').append(`
                <div class="ContRopa" id="${v.name}-click">
                    <h1 id="${v.name}-superid" class="${v.name}">${v.label}</h1>
                </div>
            `)
            $('.ArmarioOutfits').show(500)

            $(`#${v.name}-click`).click(function(){
                let puta =  $(`#${v.name}-superid`).attr('class')
                $.post('https://Roda_GangsCreator/clothes', JSON.stringify({
                    skin: puta
                }))
            })

        break;
        
        case 'closeAll':
            CloseAll()
        break;


        case 'showNoti': 
            ShowNoti(v.message, v.timeout, v.title)
        break;

        case 'openBossMenu': 
            $('.ContGangMembers').append(`
            <div class="MemberGang" id="${v.identifier}-click">
                <h1 id="${v.identifier}">${v.name}</h1>
            </div>
            `)
            $('.BossMenu').show(500)
            $(`#${v.identifier}-click`).click(function(){
                $('#putitainvisible2').attr('class', v.name)
                $('#updateUserName').text(`Manage ${v.name}`)	
                $('#updateUserName').attr('class', v.identifier)
                $('.ModalForMembers').show(500)
            })
        break;

        case 'openGarage':
            $('.GarageMenu').show(500)

            $('.vehicle-list').append(`
            <div class="vehicle-append">
                <h2>${v.label} (${v.name})</h2>
                <input class="sacarCoche-${v.name}" id="${v.name}" type="button" value="Get">
            </div>
            `)

            $(`.sacarCoche-${v.name}`).click(function(){
                let model = $(`.sacarCoche-${v.name}`).attr('id')
                $.post('https://Roda_GangsCreator/spawnVehicle', JSON.stringify({
                    model: model
                }))
            })
        break;
    }
});

$(document).keyup((e) => {
    if (e.key === "Escape") {
        CloseAll()
    }
});

$(function (){
    $('.close').click(function(){
        CloseAll()
    })

    $('#createGangs').click(function(){
        $('.menu').hide(500)
        $('.gangCreator').show(500)
    })

    $('#manageGangs').click(function(){
        $('.menu').hide(500)
        $.post('https://Roda_GangsCreator/requestGangs', JSON.stringify({
            gangname : $('#putitainvisible').attr('class')
        }));
        $('.GangManager').show(500)
    })

    $('#createClothes').click(function(){
        $('.GangManager').hide()
        point = 'clothes'

        $.post('https://Roda_GangsCreator/makeClothes', JSON.stringify({
            gangname: $('#putitainvisible').attr('class'),
            type: point
        }));
    })

    $('#savePoints').click(function(){
        CloseAll()
        $.post('https://Roda_GangsCreator/saveAllPoints', JSON.stringify({
            gangname: $('#putitainvisible').attr('class')
        }));
    })
    

    $('.butonSaveCar').click(function(){
        let model = $('.vehicleNameSearch').val()
        let label = $('.vehicleLabelSearch').val()
        let gang =  $('#putitainvisible').attr('class')
        let labelGang = $('.setText').attr('id')
        $.post('https://Roda_GangsCreator/saveVehicleInDataBase', JSON.stringify({
            model: model, 
            label: label || 'Car',
            gang : gang,
            labelGang : labelGang
        }));
    })

    $('.savemale').click(function(){
        let model = $('.outfitLabelSave').val()
        let gang =  $('#putitainvisible').attr('class')
        $.post('https://Roda_GangsCreator/getSkin', JSON.stringify({
            skin : 'male',
            label: model || 'none',
            gang: gang
        }));
    })

    $('.savefemale').click(function(){
        let model = $('.outfitLabelSave').val()
        let gang =  $('#putitainvisible').attr('class')
        $.post('https://Roda_GangsCreator/getSkin', JSON.stringify({
            skin : 'female',
            label: model || 'none',
            gang: gang
        }));
    })

    $('#createDeposit').click(function(){
        $('.GangManager').hide()
        point = 'deposit'

        $.post('https://Roda_GangsCreator/makeClothes', JSON.stringify({
            gangname: $('#putitainvisible').attr('class'),
            type: point
        }));
    })  

    $('.butonSendNewMember').click(function(){
        var pid = $('#putitainvisible3').attr('class')
        var name = $('#putitainvisible4').attr('class')
        var option = $('#ListaDeUsuariosNewsXD').val()

        $.post('https://Roda_GangsCreator/sendNewMember', JSON.stringify({
            pid : pid,
            name : name,
            option: option
        }));
    })

    $('.butonSendBoss').click(function(){
        var rango = $('#ListaDeUsuariosXD').val()
        var identifier =  $('#updateUserName').attr('class')
        var nombre =  $('#putitainvisible2').attr('class')
        $.post('https://Roda_GangsCreator/SetNewRange', JSON.stringify({
            rango: rango,
            identifier: identifier,
            nombre: nombre
        }));
        // CloseAll()
    })

    $('.butonFire').click(function(){
        var identifier =  $('#updateUserName').attr('class')
        $.post('https://Roda_GangsCreator/DeleteNewRange', JSON.stringify({
            identifier: identifier
        }));
    })

    $('#bossPoint').click(function(){
        $('.GangManager').hide()
        point = 'boss'

        $.post('https://Roda_GangsCreator/makeClothes', JSON.stringify({
            gangname: $('#putitainvisible').attr('class'),
            type: point
        }));
    })

    $('#vehicleDeposit').click(function(){
        $('.GangManager').hide()
        point = 'vehicle'

        $.post('https://Roda_GangsCreator/makeClothes', JSON.stringify({
            gangname: $('#putitainvisible').attr('class'),
            type: point
        }));
    })

    $('#gangLogo').on('keyup change', function(){
        var logo = $(this).val()
        $('.rightSideLogo img').attr('src', logo)
    })

    var GangColor = null

    $("#gangcolorxd").change(function(event) {
        GangColor = $(this).val()
    });

    $('.butonAccept').click(function(){
        var jefe = $('.putitoInvisible').attr('id')
        var target = $('.putitoInvisible2').attr('id')
        var gang = $('.putitoInvisible3').attr('id')
        var rango = $('.putitoInvisible4').attr('id')
        $.post('https://Roda_GangsCreator/acceptNewMember', JSON.stringify({
            jefe: jefe,
            target: target,
            gang: gang,
            rango: rango
        }));
    })

    $('.butonDenied').click(function(){
        var jefe = $('.putitoInvisible').attr('id')
        var target = $('.putitoInvisible2').attr('id')
        var gang = $('.putitoInvisible3').attr('id')
        var rango = $('.putitoInvisible4').attr('id')
        $.post('https://Roda_GangsCreator/deniedMember', JSON.stringify({
            jefe: jefe,
            target: target,
            gang: gang,
            rango: rango
        }));
    })

    

    $('.butonPe').click(function(){
        var name = $('#gangName').val()
        var logo = $('#gangLogo').val()
        var label = $('#gangLabel').val()
        var esposar = $('#checkbox10').is(':checked')
        var search = $('#checkbox11').is(':checked')
        var drag = $('#checkbox12').is(':checked')
        var request = $('#checkbox13').is(':checked')

        $.post('https://Roda_GangsCreator/sendGang', JSON.stringify({
            name: name || 'NULL',
            logo: logo || 'https://cdn.discordapp.com/attachments/937063390961074226/965584076344025088/logorojo.png',
            label: label || 'NULL',
            esposar: esposar,
            search: search,
            drag: drag,
            request: request,
            GangColor : GangColor
        }));
        CloseAll()
    })

    $('#searchGangs').on('keyup', function(){
        let value = $(this).val().toLowerCase()

        $('.GangInfos').filter(function(){
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        })
    })


    $('#searchMembers').on('keyup', function(){
        let value = $(this).val().toLowerCase()

        $('.MemberGang').filter(function(){
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        })
    })

    $('#searchPp').on('keyup', function(){
        let value = $(this).val().toLowerCase()

        $('.contPlayersNews').filter(function(){
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        })
    })
})

function CloseAll() {
    $('.Container').hide(500);
    $('.gangCreator').hide(500)
    $('.menuGangsters').hide(500)
    $('.GangManager').hide(500)
    $('.ContainerOfGangs').hide(500)
    $('.OptionxD').remove()
    $('input[type=text]').val('')
    $('.ContainerGangsSearch').show()
    $('.GangInfos').remove()
    $('.ModalForMembers').hide(500)
    $('.ContainerOfGangs').hide(500)
    $('.MemberGang').remove()
    $('.ArmarioOutfits').hide(500)
    $('.ContRopa').remove()
    $('.ModalForNewMembers').hide(200)
    $('.PlayerInfoxD').remove()
    $('.BossMenu').hide(500)
    $('.idCard').hide(500)
    $('.GarageMenu').hide(500)
    $('.ModalAcceptOrNot').hide(500)
    $('.ReclutMembers').hide(400)
    $('.vehicle-append').remove()
    $('.centerSearch').show()
    $('.setText').text('Manage Current Gangs!')
    $("input[type='checkbox']").prop("checked", false);
    $('.rightSideLogo img').attr('src', 'https://cdn.discordapp.com/attachments/930160016525250621/951189780601925642/rodalogo.png')
    $.post('https://Roda_GangsCreator/exit', JSON.stringify({}));
}

function imgError(img) {
    img.error="";
    img.src="https://cdn.discordapp.com/attachments/930160016525250621/951189780601925642/rodalogo.png";
}

function ShowNoti(message, timeout, title) {
    var sound = null;
    var id = $('.NotificationError .notify-append').length;

    $('.NotificationError').show(500)
    if (title == 'Success') { 
        $('.NotificationError').append(`
        <div id="${id}" class="notify-append" style = "background-color:green" >
            <h1>${title}</h1>
            <p>${message}</p>
        </div>
        `)
    } else {
        $('.NotificationError').append(`
        <div id="${id}" class="notify-append">
            <h1>${title}</h1>
            <p>${message}</p>
        </div>
        `)
    }


    if (sound != null) {
        sound.pause();
    }

    sound = new Howl({src: ['https://cdn.discordapp.com/attachments/961704227019837501/966728282437451786/error.mp3']});
    sound.volume(0.5);
    sound.play();
    
    setTimeout(function () {
        var $this = $(`.NotificationError .notify-append[id=${id}]`);

        $this.hide(500)
    }, timeout)
}