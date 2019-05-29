package id.csui.bazdat.toysrent.repository;

import id.csui.bazdat.toysrent.model.Address;

public interface AddressRepository {

    Address save(Address address);
    Address getById(String name, String noKtp);
}
