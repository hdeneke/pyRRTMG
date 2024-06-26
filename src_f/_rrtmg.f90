subroutine init ( cpdair )
! Modules used
    use rrtmg_lw_init, only: rrtmg_lw_ini
    use rrtmg_sw_init, only: rrtmg_sw_ini
    use parkind, only: rb => kind_rb
! Inputs
    real(kind=8), intent(in) :: cpdair

    call rrtmg_sw_ini(cpdair)
    call rrtmg_lw_ini(cpdair)
end subroutine init

! see _rrtm_radiation for the python that prepares these arguments...
subroutine flxhr &
    (nbndlw, nbndsw, naerec, ncol, nlay, icld, iaer, &
    permuteseed_sw, permuteseed_lw, irng, idrv, play, plev, &
    tlay, tlev, tsfc, h2ovmr, o3vmr, co2vmr, ch4vmr, n2ovmr, &
    o2vmr, cfc11vmr, cfc12vmr, cfc22vmr, ccl4vmr, aldif, aldir, asdif, &
    asdir, emis, coszen, adjes, dyofyr, scon, &
    inflgsw, inflglw, iceflgsw, iceflglw, liqflgsw, liqflglw, tauc_sw, tauc_lw, cldfrac, ssac_sw, asmc_sw, &
    fsfc_sw, ciwp, clwp, reic, relq, &
    tauaer_sw, ssaaer_sw, asmaer_sw, ecaer_sw, tauaer_lw, &
    swuflx, swdflx, swdirflx, swhr, swuflxc, swdflxc, swdirflxc, swhrc, &
    lwuflx, lwdflx, lwhr, lwuflxc, lwdflxc, lwhrc, lwduflx_dt, lwduflxc_dt )

! Modules                                              
    use rrtmg_lw_rad, only: rrtmg_lw
    use rrtmg_sw_rad, only: rrtmg_sw
    use parkind, only: im => kind_im
    use mcica_subcol_gen_lw, only: mcica_subcol_lw
    use mcica_subcol_gen_sw, only: mcica_subcol_sw
    
! Input
    integer, parameter :: rb = selected_real_kind(12)
    integer(kind=im), intent(in) :: nbndlw
    integer(kind=im), intent(in) :: nbndsw
    integer(kind=im), intent(in) :: naerec
!     integer(kind=im), intent(in) :: iplon
    integer(kind=im), intent(in) :: ncol
    integer(kind=im), intent(in) :: nlay
    integer(kind=im), intent(inout) :: icld
    integer(kind=im), intent(inout) :: iaer
    integer(kind=im), intent(in) :: permuteseed_sw
    integer(kind=im), intent(in) :: permuteseed_lw
    integer(kind=im), intent(inout) :: irng
    integer(kind=im), intent(in) :: idrv
    real(kind=rb), intent(in) :: play(ncol,nlay)
    real(kind=rb), intent(in) :: plev(ncol,nlay+1)
    real(kind=rb), intent(in) :: tlay(ncol,nlay)
    real(kind=rb), intent(in) :: tlev(ncol,nlay+1)
    real(kind=rb), intent(in) :: tsfc(ncol)
    real(kind=rb), intent(in) :: h2ovmr(ncol,nlay)
    real(kind=rb), intent(in) :: o3vmr(ncol,nlay)
    real(kind=rb), intent(in) :: co2vmr(ncol,nlay)
    real(kind=rb), intent(in) :: ch4vmr(ncol,nlay)
    real(kind=rb), intent(in) :: n2ovmr(ncol,nlay)
    real(kind=rb), intent(in) :: o2vmr(ncol,nlay)
    real(kind=rb), intent(in) :: cfc11vmr(ncol,nlay)
    real(kind=rb), intent(in) :: cfc12vmr(ncol,nlay)
    real(kind=rb), intent(in) :: cfc22vmr(ncol,nlay)
    real(kind=rb), intent(in) :: ccl4vmr(ncol,nlay)
    real(kind=rb), intent(in) :: aldif(ncol)
    real(kind=rb), intent(in) :: aldir(ncol)
    real(kind=rb), intent(in) :: asdif(ncol)
    real(kind=rb), intent(in) :: asdir(ncol)
    real(kind=rb), intent(in) :: emis(ncol,nbndlw)
    real(kind=rb), intent(in) :: coszen(ncol)
    real(kind=rb), intent(in) :: adjes
    integer(kind=im), intent(in) :: dyofyr
    real(kind=rb), intent(in) :: scon
    integer(kind=im), intent(in) :: inflgsw
    integer(kind=im), intent(in) :: inflglw
    integer(kind=im), intent(in) :: iceflgsw
    integer(kind=im), intent(in) :: iceflglw
    integer(kind=im), intent(in) :: liqflgsw
    integer(kind=im), intent(in) :: liqflglw
    real(kind=rb), intent(in) :: cldfrac(ncol,nlay)
    real(kind=rb), intent(in) :: tauc_sw(nbndsw,ncol,nlay)
    real(kind=rb), intent(in) :: tauc_lw(nbndlw,ncol,nlay)
    real(kind=rb), intent(in) :: ssac_sw(nbndsw,ncol,nlay)
    real(kind=rb), intent(in) :: asmc_sw(nbndsw,ncol,nlay)
    real(kind=rb), intent(in) :: fsfc_sw(nbndsw,ncol,nlay)
    real(kind=rb), intent(in) :: ciwp(ncol,nlay)
    real(kind=rb), intent(in) :: clwp(ncol,nlay)
    real(kind=rb), intent(in) :: reic(ncol,nlay)
    real(kind=rb), intent(in) :: relq(ncol,nlay)
    real(kind=rb), intent(in) :: tauaer_sw(ncol,nlay,nbndsw)
    real(kind=rb), intent(in) :: ssaaer_sw(ncol,nlay,nbndsw)
    real(kind=rb), intent(in) :: asmaer_sw(ncol,nlay,nbndsw)
    real(kind=rb), intent(in) :: ecaer_sw(ncol,nlay,naerec)    
    real(kind=rb), intent(in) :: tauaer_lw(ncol,nlay,nbndlw)

! Output
    ! SW
    real(kind=rb), intent(out) :: swuflx(ncol,nlay+1)       ! Total sky shortwave upward flux (W/m2)
    real(kind=rb), intent(out) :: swdflx(ncol,nlay+1)       ! Total sky shortwave downward flux (W/m2)
    real(kind=rb), intent(out) :: swdirflx(ncol,nlay+1)     ! Total sky shortwave direct flux (W/m2)
    real(kind=rb), intent(out) :: swhr(ncol,nlay)         ! Total sky shortwave radiative heating rate (K/d)
    real(kind=rb), intent(out) :: swuflxc(ncol,nlay+1)      ! Clear sky shortwave upward flux (W/m2)
    real(kind=rb), intent(out) :: swdflxc(ncol,nlay+1)      ! Clear sky shortwave downward flux (W/m2)
    real(kind=rb), intent(out) :: swdirflxc(ncol,nlay+1)      ! Clear sky shortwave direct flux (W/m2)
    real(kind=rb), intent(out) :: swhrc(ncol,nlay)        ! Clear sky shortwave radiative heating rate (K/d)
                                                
    ! LW
    real(kind=rb), intent(out) :: lwuflx(ncol,nlay+1)         ! Total sky longwave upward flux (W/m2)
    real(kind=rb), intent(out) :: lwdflx(ncol,nlay+1)         ! Total sky longwave downward flux (W/m2)
    real(kind=rb), intent(out) :: lwhr(ncol,nlay)           ! Total sky longwave radiative heating rate (K/d)
    real(kind=rb), intent(out) :: lwuflxc(ncol,nlay+1)        ! Clear sky longwave upward flux (W/m2)
    real(kind=rb), intent(out) :: lwdflxc(ncol,nlay+1)        ! Clear sky longwave downward flux (W/m2)
    real(kind=rb), intent(out) :: lwhrc(ncol,nlay)          ! Clear sky longwave radiative heating rate (K/d)

    real(kind=rb), intent(out) :: lwduflx_dt(ncol,nlay+1)
    real(kind=rb), intent(out) :: lwduflxc_dt(ncol,nlay+1)

    ! Local
    real(kind=rb) :: cldfmcl_sw(112,ncol,nlay)
    real(kind=rb) :: taucmcl_sw(112,ncol,nlay)
    real(kind=rb) :: ssacmcl_sw(112,ncol,nlay)
    real(kind=rb) :: asmcmcl_sw(112,ncol,nlay)
    real(kind=rb) :: fsfcmcl_sw(112,ncol,nlay)
    real(kind=rb) :: ciwpmcl_sw(112,ncol,nlay)
    real(kind=rb) :: clwpmcl_sw(112,ncol,nlay)
    real(kind=rb) :: reicmcl_sw(ncol,nlay)
    real(kind=rb) :: relqmcl_sw(ncol,nlay)
    real(kind=rb) :: cldfmcl_lw(140,ncol,nlay)
    real(kind=rb) :: taucmcl_lw(140,ncol,nlay)
    real(kind=rb) :: ciwpmcl_lw(140,ncol,nlay)
    real(kind=rb) :: clwpmcl_lw(140,ncol,nlay)
    real(kind=rb) :: reicmcl_lw(ncol,nlay)
    real(kind=rb) :: relqmcl_lw(ncol,nlay)

! Shortwave calculations
    call mcica_subcol_sw(1, ncol, nlay, icld, permuteseed_sw, irng, play, &
                       cldfrac, ciwp, clwp, reic, relq, tauc_sw, ssac_sw, asmc_sw, fsfc_sw, &
                       cldfmcl_sw, ciwpmcl_sw, clwpmcl_sw, reicmcl_sw, relqmcl_sw, &
                       taucmcl_sw, ssacmcl_sw, asmcmcl_sw, fsfcmcl_sw)
    call rrtmg_sw(ncol    ,nlay    ,icld    , iaer, &
             play    ,plev    ,tlay    ,tlev    ,tsfc   , &
             h2ovmr , o3vmr   ,co2vmr  ,ch4vmr  ,n2ovmr ,o2vmr , &
             asdir   ,asdif   ,aldir   ,aldif   , &
             coszen  ,adjes   ,dyofyr  ,scon, 0, &
             inflgsw ,iceflgsw,liqflgsw,cldfmcl_sw , &
             taucmcl_sw ,ssacmcl_sw ,asmcmcl_sw ,fsfcmcl_sw , &
             ciwpmcl_sw ,clwpmcl_sw ,reicmcl_sw ,relqmcl_sw , &
             tauaer_sw  ,ssaaer_sw ,asmaer_sw  ,ecaer_sw   , &
             swuflx, swdflx, swdirflx, swhr, swuflxc ,swdflxc, swdirflxc, swhrc)

! Longwave calculations
    call mcica_subcol_lw(1, ncol, nlay, icld, permuteseed_lw, irng, play, &
                       cldfrac, ciwp, clwp, reic, relq, tauc_lw, cldfmcl_lw, &
                       ciwpmcl_lw, clwpmcl_lw, reicmcl_lw, relqmcl_lw, taucmcl_lw)
    call rrtmg_lw(ncol    ,nlay    ,icld    ,idrv    , &
             play    ,plev    ,tlay    ,tlev    ,tsfc    , & 
             h2ovmr  ,o3vmr   ,co2vmr  ,ch4vmr  ,n2ovmr  ,o2vmr , &
             cfc11vmr,cfc12vmr,cfc22vmr,ccl4vmr ,emis    , &
             inflglw ,iceflglw,liqflglw,cldfmcl_lw , &
             taucmcl_lw ,ciwpmcl_lw ,clwpmcl_lw ,reicmcl_lw ,relqmcl_lw , &
             tauaer_lw  , &
             lwuflx  ,lwdflx  ,lwhr    ,lwuflxc ,lwdflxc,  lwhrc, &
             lwduflx_dt,lwduflxc_dt )

end subroutine flxhr


! see _rrtm_radiation for the python that prepares these arguments...
subroutine flxhr_sw &
    (nbndsw, naerec, ncol, nlay, icld, iaer, &
    permuteseed_sw, irng, play, plev, &
    tlay, tlev, tsfc, h2ovmr, o3vmr, co2vmr, ch4vmr, n2ovmr, &
    o2vmr, aldif, aldir, asdif, &
    asdir, coszen, adjes, dyofyr, scon, &
    inflgsw, iceflgsw, liqflgsw, tauc_sw, cldfrac, ssac_sw, asmc_sw, &
    fsfc_sw, ciwp, clwp, reic, relq, &
    tauaer_sw, ssaaer_sw, asmaer_sw, ecaer_sw, &
    swuflx, swdflx, swdirflx, swhr, swuflxc, swdflxc, swdirflxc, swhrc )

! Modules                                              
    use rrtmg_sw_rad, only: rrtmg_sw
    use parkind, only: im => kind_im
    use mcica_subcol_gen_sw, only: mcica_subcol_sw
    
! Input
    integer, parameter :: rb = selected_real_kind(12)
    integer(kind=im), intent(in) :: nbndsw
    integer(kind=im), intent(in) :: naerec
!     integer(kind=im), intent(in) :: iplon
    integer(kind=im), intent(in) :: ncol
    integer(kind=im), intent(in) :: nlay
    integer(kind=im), intent(inout) :: icld
    integer(kind=im), intent(inout) :: iaer
    integer(kind=im), intent(in) :: permuteseed_sw
    integer(kind=im), intent(inout) :: irng
    real(kind=rb), intent(in) :: play(ncol,nlay)
    real(kind=rb), intent(in) :: plev(ncol,nlay+1)
    real(kind=rb), intent(in) :: tlay(ncol,nlay)
    real(kind=rb), intent(in) :: tlev(ncol,nlay+1)
    real(kind=rb), intent(in) :: tsfc(ncol)
    real(kind=rb), intent(in) :: h2ovmr(ncol,nlay)
    real(kind=rb), intent(in) :: o3vmr(ncol,nlay)
    real(kind=rb), intent(in) :: co2vmr(ncol,nlay)
    real(kind=rb), intent(in) :: ch4vmr(ncol,nlay)
    real(kind=rb), intent(in) :: n2ovmr(ncol,nlay)
    real(kind=rb), intent(in) :: o2vmr(ncol,nlay)
    real(kind=rb), intent(in) :: aldif(ncol)
    real(kind=rb), intent(in) :: aldir(ncol)
    real(kind=rb), intent(in) :: asdif(ncol)
    real(kind=rb), intent(in) :: asdir(ncol)
    real(kind=rb), intent(in) :: coszen(ncol)
    real(kind=rb), intent(in) :: adjes
    integer(kind=im), intent(in) :: dyofyr
    real(kind=rb), intent(in) :: scon
    integer(kind=im), intent(in) :: inflgsw
    integer(kind=im), intent(in) :: iceflgsw
    integer(kind=im), intent(in) :: liqflgsw
    real(kind=rb), intent(in) :: cldfrac(ncol,nlay)
    real(kind=rb), intent(in) :: tauc_sw(nbndsw,ncol,nlay)
    real(kind=rb), intent(in) :: ssac_sw(nbndsw,ncol,nlay)
    real(kind=rb), intent(in) :: asmc_sw(nbndsw,ncol,nlay)
    real(kind=rb), intent(in) :: fsfc_sw(nbndsw,ncol,nlay)
    real(kind=rb), intent(in) :: ciwp(ncol,nlay)
    real(kind=rb), intent(in) :: clwp(ncol,nlay)
    real(kind=rb), intent(in) :: reic(ncol,nlay)
    real(kind=rb), intent(in) :: relq(ncol,nlay)
    real(kind=rb), intent(in) :: tauaer_sw(ncol,nlay,nbndsw)
    real(kind=rb), intent(in) :: ssaaer_sw(ncol,nlay,nbndsw)
    real(kind=rb), intent(in) :: asmaer_sw(ncol,nlay,nbndsw)
    real(kind=rb), intent(in) :: ecaer_sw(ncol,nlay,naerec)    

! Output
    ! SW
    real(kind=rb), intent(out) :: swuflx(ncol,nlay+1)       ! Total sky shortwave upward flux (W/m2)
    real(kind=rb), intent(out) :: swdflx(ncol,nlay+1)       ! Total sky shortwave downward flux (W/m2)
    real(kind=rb), intent(out) :: swdirflx(ncol,nlay+1)     ! Total sky shortwave direct flux (W/m2)
    real(kind=rb), intent(out) :: swhr(ncol,nlay)         ! Total sky shortwave radiative heating rate (K/d)
    real(kind=rb), intent(out) :: swuflxc(ncol,nlay+1)      ! Clear sky shortwave upward flux (W/m2)
    real(kind=rb), intent(out) :: swdflxc(ncol,nlay+1)      ! Clear sky shortwave downward flux (W/m2)
    real(kind=rb), intent(out) :: swdirflxc(ncol,nlay+1)      ! Clear sky shortwave direct flux (W/m2)
    real(kind=rb), intent(out) :: swhrc(ncol,nlay)        ! Clear sky shortwave radiative heating rate (K/d)
                                                
    ! Local
    real(kind=rb) :: cldfmcl_sw(112,ncol,nlay)
    real(kind=rb) :: taucmcl_sw(112,ncol,nlay)
    real(kind=rb) :: ssacmcl_sw(112,ncol,nlay)
    real(kind=rb) :: asmcmcl_sw(112,ncol,nlay)
    real(kind=rb) :: fsfcmcl_sw(112,ncol,nlay)
    real(kind=rb) :: ciwpmcl_sw(112,ncol,nlay)
    real(kind=rb) :: clwpmcl_sw(112,ncol,nlay)
    real(kind=rb) :: reicmcl(ncol,nlay)
    real(kind=rb) :: relqmcl(ncol,nlay)

! Shortwave calculations
    call mcica_subcol_sw(1, ncol, nlay, icld, permuteseed_sw, irng, play, &
                       cldfrac, ciwp, clwp, reic, relq, tauc_sw, ssac_sw, asmc_sw, fsfc_sw, &
                       cldfmcl_sw, ciwpmcl_sw, clwpmcl_sw, reicmcl, relqmcl, &
                       taucmcl_sw, ssacmcl_sw, asmcmcl_sw, fsfcmcl_sw)
    call rrtmg_sw(ncol    ,nlay    ,icld    , iaer, &
             play    ,plev    ,tlay    ,tlev    ,tsfc   , &
             h2ovmr , o3vmr   ,co2vmr  ,ch4vmr  ,n2ovmr ,o2vmr , &
             asdir   ,asdif   ,aldir   ,aldif   , &
             coszen  ,adjes   ,dyofyr  ,scon, 0, &
             inflgsw ,iceflgsw,liqflgsw,cldfmcl_sw , &
             taucmcl_sw ,ssacmcl_sw ,asmcmcl_sw ,fsfcmcl_Sw , &
             ciwpmcl_sw ,clwpmcl_sw ,reicmcl ,relqmcl , &
             tauaer_sw  ,ssaaer_sw ,asmaer_sw  ,ecaer_sw   , &
             swuflx, swdflx, swdirflx, swhr, swuflxc ,swdflxc, swdirflxc, swhrc)

end subroutine flxhr_sw

subroutine flxhr_lw &
    (nbndlw, ncol, nlay, icld, iaer, &
    permuteseed_lw, irng, idrv, play, plev, &
    tlay, tlev, tsfc, h2ovmr, o3vmr, co2vmr, ch4vmr, n2ovmr, &
    o2vmr, cfc11vmr, cfc12vmr, cfc22vmr, ccl4vmr, &
    emis, &
    inflglw, iceflglw,  liqflglw, tauc_lw, cldfrac, &
    ciwp, clwp, reic, relq, &
    tauaer_lw, &
    lwuflx, lwdflx, lwhr, lwuflxc, lwdflxc, lwhrc, lwduflx_dt, lwduflxc_dt )

! Modules                                              
    use rrtmg_lw_rad, only: rrtmg_lw
    use parkind, only: im => kind_im
    use mcica_subcol_gen_lw, only: mcica_subcol_lw
    
! Input
    integer, parameter :: rb = selected_real_kind(12)
    integer(kind=im), intent(in) :: nbndlw
!     integer(kind=im), intent(in) :: iplon
    integer(kind=im), intent(in) :: ncol
    integer(kind=im), intent(in) :: nlay
    integer(kind=im), intent(inout) :: icld
    integer(kind=im), intent(inout) :: iaer
    integer(kind=im), intent(in) :: permuteseed_lw
    integer(kind=im), intent(inout) :: irng
    integer(kind=im), intent(in) :: idrv
    real(kind=rb), intent(in) :: play(ncol,nlay)
    real(kind=rb), intent(in) :: plev(ncol,nlay+1)
    real(kind=rb), intent(in) :: tlay(ncol,nlay)
    real(kind=rb), intent(in) :: tlev(ncol,nlay+1)
    real(kind=rb), intent(in) :: tsfc(ncol)
    real(kind=rb), intent(in) :: h2ovmr(ncol,nlay)
    real(kind=rb), intent(in) :: o3vmr(ncol,nlay)
    real(kind=rb), intent(in) :: co2vmr(ncol,nlay)
    real(kind=rb), intent(in) :: ch4vmr(ncol,nlay)
    real(kind=rb), intent(in) :: n2ovmr(ncol,nlay)
    real(kind=rb), intent(in) :: o2vmr(ncol,nlay)
    real(kind=rb), intent(in) :: cfc11vmr(ncol,nlay)
    real(kind=rb), intent(in) :: cfc12vmr(ncol,nlay)
    real(kind=rb), intent(in) :: cfc22vmr(ncol,nlay)
    real(kind=rb), intent(in) :: ccl4vmr(ncol,nlay)
    real(kind=rb), intent(in) :: emis(ncol,nbndlw)
    integer(kind=im), intent(in) :: inflglw
    integer(kind=im), intent(in) :: iceflglw
    integer(kind=im), intent(in) :: liqflglw
    real(kind=rb), intent(in) :: cldfrac(ncol,nlay)
    real(kind=rb), intent(in) :: tauc_lw(nbndlw,ncol,nlay)
    real(kind=rb), intent(in) :: ciwp(ncol,nlay)
    real(kind=rb), intent(in) :: clwp(ncol,nlay)
    real(kind=rb), intent(in) :: reic(ncol,nlay)
    real(kind=rb), intent(in) :: relq(ncol,nlay)
    real(kind=rb), intent(in) :: tauaer_lw(ncol,nlay,nbndlw)

! Output
    ! LW
    real(kind=rb), intent(out) :: lwuflx(ncol,nlay+1)         ! Total sky longwave upward flux (W/m2)
    real(kind=rb), intent(out) :: lwdflx(ncol,nlay+1)         ! Total sky longwave downward flux (W/m2)
    real(kind=rb), intent(out) :: lwhr(ncol,nlay)           ! Total sky longwave radiative heating rate (K/d)
    real(kind=rb), intent(out) :: lwuflxc(ncol,nlay+1)        ! Clear sky longwave upward flux (W/m2)
    real(kind=rb), intent(out) :: lwdflxc(ncol,nlay+1)        ! Clear sky longwave downward flux (W/m2)
    real(kind=rb), intent(out) :: lwhrc(ncol,nlay)          ! Clear sky longwave radiative heating rate (K/d)

    real(kind=rb), intent(out) :: lwduflx_dt(ncol,nlay+1)
    real(kind=rb), intent(out) :: lwduflxc_dt(ncol,nlay+1)

    ! Local
    real(kind=rb) :: cldfmcl_lw(140,ncol,nlay)
    real(kind=rb) :: taucmcl_lw(140,ncol,nlay)
    real(kind=rb) :: ciwpmcl_lw(140,ncol,nlay)
    real(kind=rb) :: clwpmcl_lw(140,ncol,nlay)
    real(kind=rb) :: reicmcl_lw(ncol,nlay)
    real(kind=rb) :: relqmcl_lw(ncol,nlay)

! Longwave calculations
    call mcica_subcol_lw(1, ncol, nlay, icld, permuteseed_lw, irng, play, &
                       cldfrac, ciwp, clwp, reic, relq, tauc_lw, cldfmcl_lw, &
                       ciwpmcl_lw, clwpmcl_lw, reicmcl_lw, relqmcl_lw, taucmcl_lw)
    call rrtmg_lw(ncol    ,nlay    ,icld    ,idrv    , &
             play    ,plev    ,tlay    ,tlev    ,tsfc    , & 
             h2ovmr  ,o3vmr   ,co2vmr  ,ch4vmr  ,n2ovmr  ,o2vmr , &
             cfc11vmr,cfc12vmr,cfc22vmr,ccl4vmr ,emis    , &
             inflglw ,iceflglw,liqflglw,cldfmcl_lw , &
             taucmcl_lw ,ciwpmcl_lw ,clwpmcl_lw ,reicmcl_lw ,relqmcl_lw , &
             tauaer_lw  , &
             lwuflx  ,lwdflx  ,lwhr    ,lwuflxc ,lwdflxc,  lwhrc, &
             lwduflx_dt,lwduflxc_dt )

end subroutine flxhr_lw
