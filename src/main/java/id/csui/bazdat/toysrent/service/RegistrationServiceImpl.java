package id.csui.bazdat.toysrent.service;

import id.csui.bazdat.toysrent.model.Address;
import id.csui.bazdat.toysrent.model.User;
import id.csui.bazdat.toysrent.repository.AddressRepository;
import id.csui.bazdat.toysrent.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RegistrationServiceImpl implements RegistrationService{

    private final UserRepository userDao;
    private final AddressRepository addressDao;

    @Autowired
    public RegistrationServiceImpl(UserRepository userDao, AddressRepository addressDao) {
        this.userDao = userDao;
        this.addressDao = addressDao;
    }

    @Override
    @Transactional
    public void register(User user, Address address) {

        user.setLevel("bronze");
        user.setPoint(0.0f);

        User userReturn = userDao.save(user);

        if (!userReturn.isAdmin()){
            addressDao.save(address);
        }
    }
}
