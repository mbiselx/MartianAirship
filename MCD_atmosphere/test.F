      program test
      implicit none
c---------------------------------------------------------------------------
c program for testing the call_mcd subroutine
c---------------------------------------------------------------------------

c User parameters :


      character(20)  :: outdir  = 'clim_aveEUV'
      integer :: scena	 = 1		!  1: Climatology ave solar
									!  2: Climatology min solar
									!  3: Climatology max solar
                                      !  5: dust storm tau=5 (dark dust) ave solar 
	                                !  7: warm scenario - dusty, max solar 
                                      !  8: cold scenario - low dust, min solar
                                      ! 33: Mars Year 33, with associated solar EUV

      character(100) :: outpath = 'C:\Users\Michael Biselx\Desktop\'
     &                                // 'VallisMarineris\data\'
      
      real    :: minLat    = -10.7
      real    :: maxLat    = -11.3
      integer, parameter :: LatRes  = 101
      
      real    :: minLon    = -66.99999
      real    :: maxLon    = -67.
      integer, parameter :: LonRes  = 1
      
      real    :: minAlt   = -5000.
      real    :: maxAlt   =  5000.
      integer, parameter :: AltRes = 51

      real    :: minTime   =  0.
      real    :: maxTime   = 24.
      integer, parameter :: TimeRes = 49
      
      real    :: minDate   = 0.
      real    :: maxDate   = 90.
      integer, parameter :: DateRes = 2

      real    :: errval    = 0./0. ! it's a NaN

c Allocate Memory      
      real Pressures   (LatRes, LonRes, AltRes, TimeRes, DateRes)
      real Density     (LatRes, LonRes, AltRes, TimeRes, DateRes)
      real Temperatures(LatRes, LonRes, AltRes, TimeRes, DateRes)
      real HtCapacity  (LatRes, LonRes, AltRes, TimeRes, DateRes)
      real IR_Flux     (LatRes, LonRes, AltRes, TimeRes, DateRes)
      real Sol_Flux    (LatRes, LonRes, AltRes, TimeRes, DateRes)
      real DynamicVisc (LatRes, LonRes, AltRes, TimeRes, DateRes)
      real ZonalWind   (LatRes, LonRes, AltRes, TimeRes, DateRes)
      real MeridWind   (LatRes, LonRes, AltRes, TimeRes, DateRes)
      real VertWind    (LatRes, LonRes, AltRes, TimeRes, DateRes)
      
c MCD parameters (i.e. constants):
      integer :: zkey	     = 2		! 2: height above areoid (m) (MOLA zero datum)
									! 3: height above the surface (m)
      integer :: hireskey  = 1		! switch to high resolution topography
      integer :: datekey   = 1		! "Mars date": xdate is the value of Ls
      integer :: perturkey = 1		! perturbation type: None
      real    :: seedin    = 0.		! no seed required
      real    :: gwlength  = 0.		! default gravity wave perturbation
      character(len=100) :: dset = 'C:/Users/mbiselx/MarsCD/data/' ! path to MCD datasets

c MCD inputs: 
      real z							! value of the z coordinate
      real lon						! east longitude (degrees)
      real lat						! north latitude (degrees)
      real t					        ! local time at longitude xlon 
      double precision date           ! date in solar longitude Ls (degrees)
      integer extvarkeys(100)			! extra output variables (1: yes, 0: no)
      
c MCD outputs:
      real pres						! atmospheric pressure
      real ro                         ! atmospheric density
      real temp                       ! atmospheric temperature
      real u                          ! zonal wind
      real v                          ! meridional wind
      real meanvar(5)                 ! unperturbed values of main meteorological variables
      real extvar(100)                ! extra output variables
      real seedout                    ! current value of random generator seed index
      integer ier						! call_mcd status (=0 if all went well)
      
c general use variables 
      integer h, i, j, k, l
      
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

c get user inputs 
      
c set the inputs:
      extvarkeys  = 0			        ! initialize extvarkeys to 0 
c      extvarkeys( 8) = 1              ! Air heat capacity Cp (J kg-1 K-1)
      extvarkeys(26) = 1              ! get the vertical wind
c      extvarkeys(31) = 1              ! thermal IR flux to surface (W/m2)
c      extvarkeys(32) = 1              ! solar flux to surface (W/m2)
c      extvarkeys(33) = 1              ! thermal IR flux to space (W/m2)
c      extvarkeys(54) = 1              ! Air viscosity estimation (N s m-2)

c	write(*, 11) (extvarkeys(i), i = 1,size(extvarkeys))
c 11 	format (10(I3,2X))

      write(*,*)'Starting MCD read'
      
      do l = 1,DateRes
          date = minDate + (l-1)*(maxDate-minDate)/(DateRes-1)
          if (DateRes .le. 1)  date = maxDate

          do k = 1,TimeRes
              t = minTime + (k-1)*(maxTime-minTime)/(TimeRes-1)
              if (TimeRes .le. 1)  t = maxTime
          
              do h = 1,AltRes
                  z = minAlt + (h-1)*(maxAlt-minAlt)/(AltRes-1)
                  if (AltRes .le. 1)  z = maxAlt
          
                  do i = 1,LatRes
                      lat = minLat + (i-1)*(maxLat-minLat)/(LatRes-1)
                      if (LatRes .le. 1)  lat = maxLat

                    do j = 1,LonRes
                        lon = minLon + (j-1)*(maxLon-minLon)/(LonRes-1)
                        if (LonRes .le. 1)  lon = maxLon
                  
c                     write(*,*) lat, lon, z, t
          	        call call_mcd(zkey, z, lon, lat, hireskey,
     &                          datekey, date, t, dset, scena,
     &                          perturkey, seedin, gwlength, extvarkeys,
     &                          Pressures   (i, j, h, k, l), 
     &                          Density     (i, j, h, k, l), 
     &                          Temperatures(i, j, h, k, l), 
     &                          ZonalWind   (i, j, h, k, l), 
     &                          MeridWind   (i, j, h, k, l), 
     &                          meanvar, extvar, seedout, ier)

                      if (ier.eq.0) then  ! all went well
                          HtCapacity  (i, j, h, k, l) = extvar( 8)
                          VertWind    (i, j, h, k, l) = extvar(26)
                          IR_Flux     (i, j, h, k, l) = extvar(31)
                          Sol_Flux    (i, j, h, k, l) = extvar(32)
                          DynamicVisc (i, j, h, k, l) = extvar(54)
                          
                      else if (ier.eq.17)  then ! underground object        
                          Pressures   (i, j, h, k, l) = errval
                          Density     (i, j, h, k, l) = errval
                          Temperatures(i, j, h, k, l) = errval
                          ZonalWind   (i, j, h, k, l) = errval
                          MeridWind   (i, j, h, k, l) = errval
                          HtCapacity  (i, j, h, k, l) = errval
                          HtCapacity  (i, j, h, k, l) = errval
                          IR_Flux     (i, j, h, k, l) = errval
                          Sol_Flux    (i, j, h, k, l) = errval
                          DynamicVisc (i, j, h, k, l) = errval
                          
                      else    ! something bad happened
                          write(*,*)'CALL_MCD ERROR !!'
            		        write(*,*)'     returned error code: ', ier
                          goto 99 
                      endif 
                    enddo ! Latitude
                  enddo   ! Longitude
              enddo       ! Altitude
          enddo           ! Time
      enddo               ! Date
      
      write(*,*) 'finished reading MCD, writing outputs to files'
      
      
      write(*,*)'mkdir "'//trim(outpath)//trim(outdir)//'"'
      call execute_command_line('mkdir "'//trim(outpath)//
     &                          trim(outdir)//'"')
      
      open (10, FILE=trim(outpath)//trim(outdir)//'\Dimensions.csv')
      write(10, '(*(G0.6,:,","))')' ', 'minVal', 'maxVal', 'nbSamples'
      write(10, '(*(G0.6,:,","))')'Latitude',  minLat,  maxLat,  LatRes
      write(10, '(*(G0.6,:,","))')'Longitude', minLon,  maxLon,  LonRes
      write(10, '(*(G0.6,:,","))')'Altitude',  minAlt,  maxAlt,  AltRes
      write(10, '(*(G0.6,:,","))')'Time',      minTime, maxTime, TimeRes
      write(10, '(*(G0.6,:,","))')'Date',      minDate, maxDate, DateRes
      close(10)
      
      open(11, FILE=trim(outpath)//trim(outdir)//'\Pressures.csv')
      open(12, FILE=trim(outpath)//trim(outdir)//'\Density.csv')
      open(13, FILE=trim(outpath)//trim(outdir)//'\Temperatures.csv')
      open(14, FILE=trim(outpath)//trim(outdir)//'\ZonalWind.csv')
      open(15, FILE=trim(outpath)//trim(outdir)//'\MeridWind.csv')
      if (extvarkeys( 8).eq.1) then
          open(16, FILE=trim(outpath)//trim(outdir)//'\HtCapacity.csv')
      endif
      if (extvarkeys(26).eq.1) then
          open(26, FILE=trim(outpath)//trim(outdir)//'\VertWind.csv')
      endif
      if (extvarkeys(31).eq.1) then      
         open(31, FILE=trim(outpath)//trim(outdir)//'\IR_Flux2surf.csv')
      endif
      if (extvarkeys(32).eq.1) then
          open(32, FILE=trim(outpath)//trim(outdir)//'\Sol_Flux.csv')
      endif
      if (extvarkeys(54).eq.1) then     
          open(54, FILE=trim(outpath)//trim(outdir)//'\DynamicVisc.csv')
      endif

      
      do l = 1,DateRes
          do k = 1,TimeRes
              do h = 1,AltRes
              write(11, '(*(G0.6,:,","))')Pressures   (:,:, h, k, l)
              write(12, '(*(G0.6,:,","))')Density     (:,:, h, k, l)
              write(13, '(*(G0.6,:,","))')Temperatures(:,:, h, k, l)
              write(14, '(*(G0.6,:,","))')ZonalWind   (:,:, h, k, l)
              write(15, '(*(G0.6,:,","))')MeridWind   (:,:, h, k, l)
              
              if (extvarkeys( 8).eq.1) then
                  write( 8, '(*(G0.6,:,","))')HtCapacity  (:,:, h, k, l)
              endif
              if (extvarkeys(26).eq.1) then
                  write(26, '(*(G0.6,:,","))')VertWind    (:,:, h, k, l)
               endif
              if (extvarkeys(31).eq.1) then             
                  write(31, '(*(G0.6,:,","))')IR_Flux     (:,:, h, k, l)
              endif
              if (extvarkeys(32).eq.1) then
                  write(32, '(*(G0.6,:,","))')Sol_Flux    (:,:, h, k, l)
              endif
              if (extvarkeys(54).eq.1) then
                  write(54, '(*(G0.6,:,","))')DynamicVisc (:,:, h, k, l)
              endif
              enddo        ! Altitude
          enddo            ! Time
      enddo                ! Date
      
      close(11)
      close(12)      
      close(13)
      close(14)      
      close(15)
      close( 8)
      close(26)
      close(31)
      close(32)
      close(54)
      
      write(*,*)'Done'

 99  	end