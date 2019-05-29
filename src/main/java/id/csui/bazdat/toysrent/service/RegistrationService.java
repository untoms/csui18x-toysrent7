package id.csui.bazdat.toysrent.service;

import id.csui.bazdat.toysrent.model.Address;
import id.csui.bazdat.toysrent.model.User;

public interface RegistrationService {

    void register(User user, Address address);

}
