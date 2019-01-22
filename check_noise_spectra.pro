pro check_noise_spectra $
   , only=only $
   , skip=skip $
   , just_array=just_array $
   , pause=pause

; &%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%
; GET LIST OF TARGETS
; &%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%
  
; ... look up the list of galaxies

  readcol, 'ms_file_key.txt', comment='#', format='A,X,A' $
           , ms_file_gal, ms_file_array
  gals = ms_file_gal[sort(ms_file_gal)]
  gals = gals[uniq(gals)]
  n_gals = n_elements(gals)
  
; ... look up the cases with nonstandard directory names

  readcol, 'dir_key.txt', comment='#', format='A,A' $
           , dir_key_gal, dir_key_dir
  dir_for_gal = gals
  for ii = 0, n_elements(dir_key_gal)-1 do begin
     ind = where(dir_key_gal[ii] eq gals, ct)
     if ct eq 0 then continue
     dir_for_gal[ind] = (dir_key_dir[ii])
  endfor

  fullgal_list = [dir_for_gal, gals]
  fullgal_list = fullgal_list[sort(fullgal_list)]
  fullgal_list = fullgal_list[uniq(fullgal_list)]
  n_fullgals = n_elements(fullgal_list)

  gal_for_fullgals = fullgal_list
  for ii = 0, n_elements(dir_key_gal)-1 do begin
     ind = where(dir_key_gal[ii] eq fullgal_list, ct)
     if ct eq 0 then continue
     gal_for_fullgals[ind] = (dir_key_dir[ii])
  endfor

; ARRAYS
  
  array_list = ['7m', '12m', '12m+7m']
  n_array = n_elements(array_list)

; &%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%
; LOOP OVER GALAXIES AND CHECK THEIR STATUS
; &%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%&%  

  missing = []
  missing_noms = []
  rerun = []
  okay = []

  for ii = 0, n_gals-1 do begin
     
     if n_elements(only) gt 0 then $
        if total(only eq gals[ii]) eq 0 then continue
     
     if n_elements(skip) gt 0 then $
        if total(skip eq gals[ii]) gt 0 then continue
     
     message, '... noise spectrum for '+gals[ii], /info        
     
     this_gal = gals[ii]
     this_dir = dir_for_gal[ii]

     for jj = 0, n_array - 1 do begin

        this_array = array_list[jj]

        if n_elements(just_array) gt 0 then $
           if total(just_array eq this_array) eq 0 then continue

        cube_name = '../'+this_dir+'/'+this_gal+'_'+this_array+'_co21_dirty.fits'
        if file_test(cube_name) eq 0 then $
           continue
        cube = readfits(cube_name, hdr)
        sz = size(cube)
        spec = fltarr(sz[3])
        for pp = 0, sz[3]-1 do begin
           ;spec[pp] = mad(cube[*,*,pp])
           spec[pp] = mad(cube[*,*,pp])
        endfor
        plot, findgen(sz[3]), spec, ystyle=16, ps=10 $
              , xtitle='channel', ytitle='mad' $
              , title=cube_name
        if keyword_set(pause) then begin
           print, "Key to continue."
           ch = get_kbrd(1)
        endif

     endfor

  endfor

end