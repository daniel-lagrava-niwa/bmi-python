module demo_model
  use iso_c_binding
  use iso_c_utils

  implicit none

  ! This is assumed.....
  integer(c_int), parameter :: MAXDIMS = 6

  integer, target :: var1
  double precision, target :: var2(2)
  logical(c_bool), target :: var3(2,3)
contains



  integer(c_int) function finalize() result(ierr) bind(C, name="finalize")
    !DEC$ ATTRIBUTES DLLEXPORT::finalize
    ierr = 0
    write(*,*) 'Finalize'
  end function finalize


  integer(c_int) function initialize(c_configfile) result(ierr) bind(C, name="initialize")
    !DEC$ ATTRIBUTES DLLEXPORT::initialize

    implicit none

    ! Variables
    character(kind=c_char), intent(in) :: c_configfile(*)
    character(len=strlen(c_configfile)) :: configfile

    ! Convert c string to fortran string
    ierr = 0
    configfile = char_array_to_string(c_configfile)
    write(*,*) 'Initializing with ', configfile

  end function initialize


  !> Performs a single timestep with the current model.
  integer(c_int) function update(dt) result(ierr) bind(C,name="update")
    !DEC$ ATTRIBUTES DLLEXPORT::update

    !< Custom timestep size, use -1 to use model default.
    real(c_double), intent(in) :: dt

    ierr = 0
    write(*,*) 'Updating with dt: ', dt

  end function update


  ! Void function is a subroutine
  subroutine get_var_type(c_var_name, c_type_name)  bind(C, name="get_var_type")
    !DEC$ ATTRIBUTES DLLEXPORT :: get_var_type

    character(kind=c_char), intent(in) :: c_var_name(*)
    character(kind=c_char), intent(out) :: c_type_name(MAXSTRINGLEN)

    character(len=strlen(c_var_name)) :: var_name
    character(len=MAXSTRINGLEN) :: type_name

    var_name = char_array_to_string(c_var_name)

    select case(var_name)
    case('var1')
       type_name = 'double'
    case('var2')
       type_name = 'int'
    case('var3')
       type_name = 'bool'
    case default
    end select

    c_type_name = string_to_char_array(trim(type_name))

  end subroutine get_var_type

  subroutine get_var_rank(c_var_name, rank) bind(C, name="get_var_rank")
    !DEC$ ATTRIBUTES DLLEXPORT :: get_var_rank

    character(kind=c_char), intent(in) :: c_var_name(*)
    integer(c_int), intent(out) :: rank

    ! The fortran name of the attribute name
    character(len=strlen(c_var_name)) :: var_name
    ! Store the name
    var_name = char_array_to_string(c_var_name)

    select case(var_name)
    case("var1")
       rank = 0
    case("var2")
       rank = 1
    case("var3")
       rank = 2
    case default
       rank = 0
    end select
  end subroutine get_var_rank

  subroutine get_var_shape(c_var_name, shape) bind(C, name="get_var_shape")
    !DEC$ ATTRIBUTES DLLEXPORT :: get_var_shape

    character(kind=c_char), intent(in) :: c_var_name(*)
    integer(c_int), intent(inout) :: shape(MAXDIMS)

    character(len=strlen(c_var_name)) :: var_name

    var_name = char_array_to_string(c_var_name)
    shape = (/0, 0, 0, 0, 0, 0/)

    select case(var_name)
    case("var1")
    case("var2")
       shape(1:1) = 2
    case("var3")
       shape(1:2) = (/2, 3/)
    end select
  end subroutine get_var_shape

  subroutine get_var(c_var_name, x) bind(C, name="get_var")
    !DEC$ ATTRIBUTES DLLEXPORT :: get_var

    ! Return a pointer to the variable

    character(kind=c_char), intent(in) :: c_var_name(*)
    type(c_ptr), intent(inout) :: x

    character(len=strlen(c_var_name)) :: var_name
    ! Store the name

    var_name = char_array_to_string(c_var_name)

    select case(var_name)
    case("var1")
       x = c_loc(var1)
    case("var2")
       x = c_loc(var2)
    case("var3")
       x = c_loc(var3)
    end select

  end subroutine get_var


end module demo_model

