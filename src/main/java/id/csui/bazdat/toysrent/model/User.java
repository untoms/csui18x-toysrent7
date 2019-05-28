package id.csui.bazdat.toysrent.model;

import java.util.Date;


public class User {

    private String noKtp;
    private String email;
    private String fullName;
    private String phone;
    private Date dob;

    //member attr
    private String level;
    private Float point;

    private Boolean isAdmin;

    public User() {
    }

    public User(String noKtp, String email, String fullName, String phone, Date dob, String level, Float point, Boolean isAdmin) {
        this.noKtp = noKtp;
        this.email = email;
        this.fullName = fullName;
        this.phone = phone;
        this.dob = dob;
        this.level = level;
        this.point = point;
        this.isAdmin = isAdmin;
    }

    public String getNoKtp() {
        return noKtp;
    }

    public void setNoKtp(String noKtp) {
        this.noKtp = noKtp;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public Date getDob() {
        return dob;
    }

    public void setDob(Date dob) {
        this.dob = dob;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public Float getPoint() {
        return point;
    }

    public void setPoint(Float point) {
        this.point = point;
    }

    public Boolean isAdmin() {
        return isAdmin;
    }

    public void setAdmin(Boolean admin) {
        isAdmin = admin;
    }

    @Override
    public String toString() {
        return "User{" +
                "noKtp='" + noKtp + '\'' +
                ", email='" + email + '\'' +
                ", fullName='" + fullName + '\'' +
                ", phone='" + phone + '\'' +
                ", dob=" + dob +
                ", level='" + level + '\'' +
                ", point=" + point +
                ", isAdmin=" + isAdmin +
                '}';
    }
}

