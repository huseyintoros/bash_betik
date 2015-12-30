
; Example series of plotting meteograms with WRF ARW model data
; First let's just get and plot t2 at a point
; Add some info to the plot
; Add slp to the plot
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
;***********************************************
begin
;***********************************************
;http://www.ncl.ucar.edu/Support/talk_archives/2010/1868.html
a= addfile ("wrfout_d01_2015-12-30_00.nc", "r") 

lat = 40.550278       
lon = 29.818889       
  llres = True
  llres@ReturnInt = True   ; Return integer values
  locij = wrf_user_ll_to_ij(a, lon, lat, llres)
  locij = locij - 1        ; array pointers in NCL space
  locX = locij(0)
  locY = locij(1)

  t2    = wrf_user_getvar(a,"T2",-1)    ; get t2 for all times
  slp   = wrf_user_getvar(a,"slp",-1)   ; get slp for all times
  rh    = wrf_user_getvar(a,"rh",-1)
  rain_exp = wrf_user_getvar(a,"RAINNC",-1)
  rain_con = wrf_user_getvar(a,"RAINC", -1)
  u     = wrf_user_getvar(a,"U10",-1)
  v     = wrf_user_getvar(a,"V10",-1)
  rain_tot = (rain_exp + rain_con)
  P  = a->P
  Pb = a->PB
  pn  = P + Pb
  T = a->T
  T = T + 300.
  tc = wrf_tk (pn, T)-273.15
  tc_850 = wrf_user_intrp3d(tc,pn,"h",850.,0.,False)
  rh_850 = wrf_user_intrp3d(rh,pn,"h",850.,0.,False)

  t2_point  = t2(:,locY,locX)-273               ; extract a time series at a point
  slp_point  = slp(:,locY,locX)  
  rh_point  = rh_850(:,locY,locX)
  rain_point = rain_tot(:,locY,locX)
  u_point = u(:,locY,locX)
  v_point = v(:,locY,locX)
  ws = sqrt((u_point*u_point) + (v_point*v_point))
  tc_point = tc_850(:,locY,locX)

  t2_max = max(t2_point)
  tc_max = max(tc_point)
  t2_min = min(t2_point)
  tc_min = min(tc_point)
  maxt = t2_max
  if (t2_max .lt. tc_max) then
  maxt = tc_max+0.5
  else
  maxt = t2_max+0.5
  end if
  mint = tc_min
  if (t2_min .lt. tc_min) then
  mint = t2_min-0.5
  else
  mint = tc_min-0.5
  end if

  temp = dimsizes(rain_point)
  nrain = new(temp(0),float)
  nrain(0) = rain_point(0)
  do i = 1,temp(0)-1
  nrain(i) = rain_point(i)-rain_point(i-1)
  end do

  rain_max = (max(nrain))
  if (rain_max .lt. 3) then
  maxr = 3
  end if
  if (rain_max .lt. 5 .and. rain_max .gt. 3) then
  maxr = 5
  end if
  if (rain_max .lt. 10 .and. rain_max .gt. 5) then
  maxr = 10
  end if
  if (rain_max .lt. 15 .and. rain_max .gt. 10) then
  maxr = 15
  end if
  if (rain_max .lt. 20 .and. rain_max .gt. 15) then
  maxr = 20
  end if
  if (rain_max .lt. 25 .and. rain_max .gt. 20) then
  maxr = 25
  end if
  if (rain_max .lt. 30 .and. rain_max .gt. 25) then
  maxr = 30
  end if
  if (rain_max .lt. 40 .and. rain_max .gt. 30) then
  maxr = 40
  end if
  if (rain_max .gt. 40) then
  maxr = 60
  end if



; get time information and strip out the day and hour
  times_in_file = a->Times
  dims = dimsizes(times_in_file)
  times = new(dims(0),string)
  do i=0,dims(0)-1
    times(i) = chartostring(times_in_file(i,8:12))
  end do

taus = new(dims(0),float)               ; Zaman referansi olusturma
  do i=0,dims(0)-1
  taus(i)=i+1
  end do

zaman = new(dims(0),string)            ; grafiklerin zaman araliginin birer bosluklu yazilmasi
do i=0, dims(0)-1
  if ((i % 2) .eq. 0) then
  zaman(i) = times(i)
  else
  zaman(i)=""
  end if
end do

  wks = gsn_open_wks("oldps","meteo3")    ; open a workstation

;-----------------------------------------------------------------------

  res = True                            ; Set basic resources both will use
  res@vpXF            = 0.20            ; The left side of the box location
  res@vpWidthF        = 0.70            ; The Width of the plot box
  res@vpHeightF       = 0.125            ; The height of the plot box
  res@tmXBMode       = "Explicit"       ; Define own tick mark labels.
  res@tmXBValues     = taus             ; location of explicit labels
  res@tmXBLabels     = zaman            ; labels are the locations
  res@tmXBLabelFontHeightF = .012
  res@tmYLLabelFontHeightF = .0115
  res@tmXTOn         = False            ; turn off the top tick marks
  res@xyLineThicknesses = 2             ; increase line thickness
  res@gsnDraw         = False           ; Don't draw individual plot.
  res@gsnFrame        = False           ; Don't advance frame.

  slp_res = res
  slp_res@vpYF            = 0.365        ; The top side of the plot box loc
  slp_res@xyLineColor    =  "orange"       ; set line color
  slp_res@tiYAxisString  = "Basinc (mb)"

  t2_res = res
  t2_res@vpYF            = 0.175         ; The top side of the plot box loc
  t2_res@xyLineColor    =  "blue"       ; set line color
  t2_res@tiYAxisString = "2m & 850mb Sicaklik"
  t2_res@trYMinF = mint 
  t2_res@trYMaxF = maxt 
  
  t2_res@pmLegendDisplayMode    = "Always"   ; Display a legend.
  t2_res@xyExplicitLegendLabels = " 2m Sicaklik"
  t2_res@lgJustification        = "TopRight"
  t2_res@pmLegendOrthogonalPosF = -1.53     ; Move into plot
  t2_res@pmLegendParallelPosF   = 1       ; Move to right
  t2_res@pmLegendWidthF         = 0.1       ; Decrease width
  t2_res@pmLegendHeightF        = 0.025       ; Decrease height
  t2_res@lgBoxMinorExtentF      = 0.18       ; Shorten the legend lines
  t2_res@lgLabelFontHeightF     = 0.012     ; Change the font size

  rh_res = res
  rh_res@vpYF            = 0.555
  rh_res@xyLineColor    = "green"
  rh_res@tiYAxisString  = "850mb Nem %"
  ws_res = res
  ws_res@vpYF          =0.745
  ws_res@xyLineColor   = "black"
  ws_res@tiYAxisString = "Ruzgar (10m, m/s)"
  rain_res = res
  rain_res@vpYF            = 0.935
  rain_res@xyLineColor    = "blue"
  rain_res@gsnYRefLine     = 0.0              ; create a reference line
  rain_res@gsnAboveYRefLineColor = "blue"    ; above ref line fill green
  rain_res@gsnXYBarChart   = True             ; turn on bar chart
  rain_res@trYMinF = 0.0 ; min value on y-axis
  rain_res@trYMaxF = maxr ; min value on y-axis
  rain_res@tiYAxisString = "Yagis (mm)"
rain_res@tiMainString = "RG-12"       
 
  tc_res = res
  tc_res@vpYF            = 0.175         ; The top side of the plot box loc
  tc_res@xyLineColor    =  "red"       ; set line color
  tc_res@tiYAxisString = "2m T(C)"


  slp_plot  = gsn_csm_xy(wks,taus,slp_point,slp_res)       
  t2_plot  = gsn_csm_xy(wks,taus,t2_point,t2_res)
  rh_plot  = gsn_csm_xy(wks,taus,rh_point,rh_res)
  ws_plot = gsn_csm_xy(wks,taus,ws,ws_res)
  rain_plot = gsn_csm_xy(wks,taus,nrain,rain_res)
  tc_plot = gsn_csm_xy(wks,taus,tc_point,tc_res)
  overlay(t2_plot,tc_plot)
  draw(rain_plot)
  draw(rh_plot)
  draw(slp_plot)
  draw(ws_plot)
  draw(t2_plot)
  

  frame(wks)                            ; now frame the plot   

;-----------------------------------------------------------------------

end
