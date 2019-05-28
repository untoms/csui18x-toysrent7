package id.csui.bazdat.toysrent.repository;


import id.csui.bazdat.toysrent.model.User;

public interface UserRepository {

    User getUerByUserName(String userName);
}
