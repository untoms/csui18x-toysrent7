--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.22
-- Dumped by pg_dump version 10.5 (Ubuntu 10.5-0ubuntu0.18.04)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: calculate_point_deposit(); Type: FUNCTION; Schema: public; Owner: db2018084
--

CREATE FUNCTION public.calculate_point_deposit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
  current_point integer;
BEGIN

if TG_OP = 'INSERT' THEN

  select 
  a.poin into current_point
  from anggota a
  where a.no_ktp = NEW.no_ktp_penyewa;

  update anggota set poin = current_point + 100 where no_ktp=current_no_ktp;

  RETURN NEW;

END IF;
end;
$$;


ALTER FUNCTION public.calculate_point_deposit() OWNER TO db2018084;

--
-- Name: calculate_point_order(); Type: FUNCTION; Schema: public; Owner: db2018084
--

CREATE FUNCTION public.calculate_point_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
  current_point integer;
  current_no_ktp varchar;
BEGIN

if TG_OP = 'INSERT' THEN

  select 
  a.poin, a.no_ktp  into current_point, current_no_ktp
  from barang_pesanan b  
  left join pemesanan p on b.id_pemesanan=p.id_pemesanan
  left join anggota a on p.no_ktp_pemesan=a.no_ktp
  where b.no_urut = NEW.no_urut;

  update anggota set poin = current_point + 100 where no_ktp=current_no_ktp;

  RETURN NEW;

END IF;
end;
$$;


ALTER FUNCTION public.calculate_point_order() OWNER TO db2018084;

--
-- Name: calculate_rent_price(); Type: FUNCTION; Schema: public; Owner: db2018084
--

CREATE FUNCTION public.calculate_rent_price() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
  rent_price real;
BEGIN

if TG_OP = 'INSERT' THEN

  select ibl.harga_sewa into rent_price
  from pemesanan p 
  left join barang_pesanan bp on bp.id_pemesanan=p.id_pemesanan
  left join anggota a on p.no_ktp_pemesan=a.no_ktp
  left join level_keanggotaan l on a.level=l.nama_level
  left join info_barang_level ibl on l.nama_level=ibl.nama_level
  where ibl.id_barang = NEW.id_barang and p.id_pemesanan=NEW.id_pemesanan limit 1;

  update pemesanan set harga_sewa = rent_price where id_pemesanan=NEW.id_pemesanan;

  RETURN NEW;

END IF;
end;
$$;


ALTER FUNCTION public.calculate_rent_price() OWNER TO db2018084;

--
-- Name: calculate_shipping_price(); Type: FUNCTION; Schema: public; Owner: db2018084
--

CREATE FUNCTION public.calculate_shipping_price() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
  shipping_price real;
BEGIN

if TG_OP = 'INSERT' THEN

  select ongkos into shipping_price
  from pemesanan where id_pemesanan=NEW.id_pemesanan;

  update pemesanan set ongkos = shipping_price + NEW.ongkos where id_pemesanan=NEW.id_pemesanan;

  RETURN NEW;

END IF;
end;
$$;


ALTER FUNCTION public.calculate_shipping_price() OWNER TO db2018084;

--
-- Name: determine_level(); Type: FUNCTION; Schema: public; Owner: db2018084
--

CREATE FUNCTION public.determine_level() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
  new_point integer;
BEGIN

if TG_OP = 'UPDATE' THEN
  
  if (NEW.poin >= 1500) THEN
    update anggota set level='gold' where no_ktp=NEW.no_KTP;
  ELSIF (NEW.poin >= 1000) THEN
    update anggota set level='silver' where no_ktp=NEW.no_KTP;
  ELSIF (NEW.poin >= 500) THEN
    update anggota set level='bronze' where no_ktp=NEW.no_KTP;
  END if;

  RETURN NEW;

END IF;
end;
$$;


ALTER FUNCTION public.determine_level() OWNER TO db2018084;

--
-- Name: func_kondisi_barang(); Type: FUNCTION; Schema: public; Owner: db2018084
--

CREATE FUNCTION public.func_kondisi_barang() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF (TG_OP = 'INSERT' OR 'UPDATE') THEN
        UPDATE barang 
        SET kondisi = 'sedang disewa anggota'
        WHERE barang.id_barang = barang_pesanan.id_barang and 
        barang_pesanan.id_pemesanan = NEW.pemesanan.id_pemesanan;
        RETURN NEW;
        END IF;
        END;
$$;


ALTER FUNCTION public.func_kondisi_barang() OWNER TO db2018084;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.admin (
    no_ktp character varying(20) NOT NULL
);


ALTER TABLE public.admin OWNER TO db2018084;

--
-- Name: alamat; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.alamat (
    no_ktp_anggota character varying(20) NOT NULL,
    nama character varying(255) NOT NULL,
    jalan character varying(255) NOT NULL,
    nomor integer NOT NULL,
    kota character varying(255) NOT NULL,
    kodepos character varying(10) NOT NULL
);


ALTER TABLE public.alamat OWNER TO db2018084;

--
-- Name: anggota; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.anggota (
    no_ktp character varying(20) NOT NULL,
    poin real DEFAULT 0 NOT NULL,
    level character varying(20) NOT NULL
);


ALTER TABLE public.anggota OWNER TO db2018084;

--
-- Name: barang; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.barang (
    id_barang character varying(10) NOT NULL,
    nama_item character varying(255) NOT NULL,
    warna character varying(50),
    url_foto text,
    kondisi text NOT NULL,
    lama_penggunaan integer,
    no_ktp_penyewa character varying(20) NOT NULL
);


ALTER TABLE public.barang OWNER TO db2018084;

--
-- Name: barang_dikembalikan; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.barang_dikembalikan (
    no_resi character varying(10) NOT NULL,
    no_urut character varying(10) NOT NULL,
    id_barang character varying(10) NOT NULL
);


ALTER TABLE public.barang_dikembalikan OWNER TO db2018084;

--
-- Name: barang_dikirim; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.barang_dikirim (
    no_resi character varying(10) NOT NULL,
    no_urut character varying(10) NOT NULL,
    id_barang character varying(10) NOT NULL,
    tanggal_review date NOT NULL,
    review text NOT NULL
);


ALTER TABLE public.barang_dikirim OWNER TO db2018084;

--
-- Name: barang_pesanan; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.barang_pesanan (
    id_pemesanan character varying(10) NOT NULL,
    no_urut character varying(10) NOT NULL,
    id_barang character varying(10) NOT NULL,
    tanggal_sewa date NOT NULL,
    lama_sewa integer NOT NULL,
    tanggal_kembali date,
    status character varying(50) NOT NULL
);


ALTER TABLE public.barang_pesanan OWNER TO db2018084;

--
-- Name: chat; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.chat (
    id character varying(15) NOT NULL,
    pesan text NOT NULL,
    date_time timestamp without time zone NOT NULL,
    no_ktp_anggota character varying(20) NOT NULL,
    no_ktp_admin character varying(20) NOT NULL
);


ALTER TABLE public.chat OWNER TO db2018084;

--
-- Name: info_barang_level; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.info_barang_level (
    id_barang character varying(10) NOT NULL,
    nama_level character varying(20) NOT NULL,
    harga_sewa real NOT NULL,
    porsi_royalti real NOT NULL
);


ALTER TABLE public.info_barang_level OWNER TO db2018084;

--
-- Name: item; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.item (
    nama character varying(255) NOT NULL,
    deskripsi text,
    usia_dari integer NOT NULL,
    usia_sampai integer NOT NULL,
    bahan text
);


ALTER TABLE public.item OWNER TO db2018084;

--
-- Name: kategori; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.kategori (
    nama character varying(255) NOT NULL,
    level integer NOT NULL,
    sub_dari character varying(255) NOT NULL
);


ALTER TABLE public.kategori OWNER TO db2018084;

--
-- Name: kategori_item; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.kategori_item (
    nama_item character varying(255) NOT NULL,
    nama_kategori character varying(255) NOT NULL
);


ALTER TABLE public.kategori_item OWNER TO db2018084;

--
-- Name: level_keanggotaan; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.level_keanggotaan (
    nama_level character varying(20) NOT NULL,
    minimum_poin real NOT NULL,
    deskripsi text
);


ALTER TABLE public.level_keanggotaan OWNER TO db2018084;

--
-- Name: pemesanan; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.pemesanan (
    id_pemesanan character varying(10) NOT NULL,
    datetime_pesanan timestamp without time zone NOT NULL,
    kuantitas_barang integer NOT NULL,
    harga_sewa real DEFAULT 0,
    ongkos real DEFAULT 0,
    no_ktp_pemesan character varying(20) NOT NULL,
    status character varying(50) NOT NULL
);


ALTER TABLE public.pemesanan OWNER TO db2018084;

--
-- Name: pengembalian; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.pengembalian (
    no_resi character varying(10) NOT NULL,
    id_pemesanan character varying(10) NOT NULL,
    metode text NOT NULL,
    ongkos real NOT NULL,
    tanggal date NOT NULL,
    no_ktp_anggota character varying(20) NOT NULL,
    nama_alamat_anggota character varying(255) NOT NULL
);


ALTER TABLE public.pengembalian OWNER TO db2018084;

--
-- Name: pengguna; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.pengguna (
    no_ktp character varying(20) NOT NULL,
    nama_lengkap character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    tanggal_lahir date,
    no_telp character varying(20)
);


ALTER TABLE public.pengguna OWNER TO db2018084;

--
-- Name: pengiriman; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.pengiriman (
    no_resi character varying(10) NOT NULL,
    id_pemesanan character varying(10) NOT NULL,
    metode text NOT NULL,
    ongkos real NOT NULL,
    tanggal date NOT NULL,
    no_ktp_anggota character varying(20) NOT NULL,
    nama_alamat_anggota character varying(255) NOT NULL
);


ALTER TABLE public.pengiriman OWNER TO db2018084;

--
-- Name: status; Type: TABLE; Schema: public; Owner: db2018084
--

CREATE TABLE public.status (
    nama character varying(50) NOT NULL,
    deskripsi text
);


ALTER TABLE public.status OWNER TO db2018084;

--
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.admin (no_ktp) FROM stdin;
41-1743563
36-9622643
46-4222968
64-7046981
61-5163734
29-6736736
80-5342780
91-8332192
17-1240312
06-9997319
\.


--
-- Data for Name: alamat; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.alamat (no_ktp_anggota, nama, jalan, nomor, kota, kodepos) FROM stdin;
46-3695500	Denton	845-6506 Imperdiet Av.	12	Muzaffarpur	9836
51-1435536	Ainsley	Ap #939-2164 Etiam Avenue	5	Tierra Amarilla	584370
47-0373803	Damian	5418 Tincidunt Rd.	42	Quirihue	64209
76-4863780	Martina	Ap #370-8261 Id, Rd.	45	Fraser-Fort George	0025 PK
00-0651073	Hop	950-3791 Ullamcorper St.	22	Cholet	1412 WV
50-2730271	Tyrone	Ap #692-6989 Faucibus Street	40	Tiverton	78430
74-6347410	Velma	P.O. Box 454, 3192 Vel St.	15	Pichilemu	10994
68-1681959	Alana	540-1062 Pharetra, St.	35	Kearney	94650
73-3358461	Alexandra	Ap #364-362 Nullam Street	32	Villar Pellice	9266 JM
21-9661851	Rhoda	Ap #872-4920 Euismod Av.	18	Glovertown	49-490
73-3358461	Caesar	P.O. Box 668, 7778 Nulla St.	31	Castres	7062
51-1435536	Scarlett	672-8429 Lorem Rd.	8	Brucargo	353729
73-3358461	Rashad	3662 At, Avenue	4	Tuktoyaktuk	17585
81-9341132	Gil	Ap #155-2310 Neque Avenue	31	Pabianice	65-424
49-9416117	Martina	969-4207 Scelerisque Rd.	16	Clearwater Municipal District	72099
50-6722733	Elliott	8923 Sed Rd.	39	Winnipeg	711815
22-4950259	Caryn	5329 Pede, Ave	9	Geraldton-Greenough	17029
90-0262173	Marah	Ap #483-6162 Aliquam Road	20	Grosseto	62411
58-4832507	Gail	Ap #831-1655 Id St.	42	Antuco	3150 GS
22-4950259	Victor	P.O. Box 542, 6690 Aenean Avenue	32	Angoulême	YP4 7AD
31-1836523	Shay	7444 Ut St.	6	Rezé	75941
46-4306622	Thomas	548-224 Vitae Rd.	6	Ipswich	22-199
90-0262173	Ariana	Ap #310-8171 Netus Ave	31	Traiskirchen	828147
46-4306622	Dai	Ap #791-3701 Malesuada Avenue	29	Licantén	48
22-4950259	Tyler	9368 Interdum St.	19	Waiblingen	88082
51-1435536	Leonard	168-6784 Arcu. Street	10	Pincher Creek	5306
46-3695500	Inez	692-7318 Curabitur St.	41	Villanova d'Albenga	R4K 0X4
21-9661851	Abigail	362-6429 Cum Street	16	Limoges	8116
63-6658840	Isadora	Ap #760-128 Hendrerit Rd.	31	Devonport	41313
03-8466469	Avram	8295 Eu St.	37	Manchester	66-813
81-9341132	Emerson	P.O. Box 162, 9560 Pharetra Road	48	Cambridge Bay	614128
22-4950259	Adria	Ap #608-2495 Quisque Ave	29	Cardedu	61954
22-4950259	Chiquita	Ap #622-7602 Fusce Ave	22	Solre-sur-Sambre	45151
90-0262173	Kevin	173 Semper St.	3	Fort Resolution	61-523
05-7449820	Jessamine	Ap #385-2492 Nam Street	46	Kavaratti	8327
54-3525571	Ebony	Ap #665-2129 Tempor Rd.	23	San Nicolás	56209
03-8466469	Xantha	675-7502 Magna. Road	22	Cumberland	9028
74-6347410	Kato	P.O. Box 746, 3099 Est. Avenue	10	Gießen	95705
90-0262173	Byron	174-3309 Adipiscing St.	8	Jonesboro	95011-150
29-2122920	Merrill	8619 Magna. Av.	30	Tula	61614
89-0232531	Patricia	355-5664 Dui Av.	22	Boncelles	71818
73-3358461	Ciaran	540-8118 Duis Ave	1	Montrose	6682
90-0262173	Lunea	177-473 Augue, Street	1	Sunset Point	9473 WC
22-4950259	Kylynn	P.O. Box 134, 1374 Mollis. St.	1	Osnabrück	5125
22-4950259	Ferris	442-4117 Dolor. Av.	24	Fallais	615864
63-6658840	Raymond	9637 Magnis Rd.	3	Ludwigsfelde	92967
23-7102043	Jasper	Ap #734-4536 Ante St.	19	Augusta	90142
00-0651073	Indira	P.O. Box 596, 3134 In Ave	43	Jupille-sur-Meuse	309958
90-0262173	Ebony	6435 Cubilia St.	16	Vietri di Potenza	15348
21-9661851	Tyler	3188 Nullam Ave	29	Lloydminster	61040
63-6658840	Clayton	P.O. Box 459, 2021 Cursus Av.	16	Saint Paul	1039
90-0262173	Nissim	636-858 Hendrerit Ave	36	Millet	441526
54-8763454	Lev	P.O. Box 861, 2226 Quisque Av.	1	Barahanagar	6984
22-4950259	Dominique	P.O. Box 402, 5637 In, St.	48	Peumo	253010
68-1681959	Calvin	5933 Magna St.	46	Velletri	3815
89-0232531	Fay	202-7132 Ac St.	16	Morro Reatino	745533
25-3588974	Cain	Ap #304-1063 Adipiscing Rd.	27	Friedrichshafen	2795
49-9416117	Davis	3749 Mattis Ave	34	Rinconada	93584
63-6658840	Chaney	975-7696 Luctus. Avenue	4	Retie	31476
22-4950259	Carson	2836 Pellentesque Rd.	9	Cincinnati	T8L 7G4
71-5394236	Troy	P.O. Box 656, 6130 Aliquam St.	33	Nordhorn	784281
54-3525571	Quon	449-9509 Adipiscing, Rd.	50	San Lorenzo	U7 8SL
81-9341132	Avram	P.O. Box 489, 1247 Scelerisque Rd.	24	Chicoutimi	B8W 7Y9
90-0262173	Sade	1317 Nunc Av.	39	Kamalia	85262
31-5087250	Wayne	911-496 Suspendisse Ave	16	Sint-Gillis-Waas	363248
73-3358461	Rebecca	4516 A, Street	28	Kozan	31183
31-5087250	Geraldine	Ap #142-344 Primis Street	50	Clarksville	41100
31-5087250	Summer	Ap #760-7426 Consequat Av.	17	Cabildo	48504
54-8763454	Hall	Ap #553-4815 Tristique Av.	7	Dunbar	117771
00-0651073	Alfonso	Ap #727-1293 Egestas. Rd.	38	Oxford County	18896
31-5087250	Mikayla	5760 Mauris. Av.	49	Los Lagos	44244
31-5087250	Alan	734-8528 A, Street	7	Gatineau	PH43 4BM
03-8466469	Quinn	105-8492 Sit Av.	25	San Venanzo	177983
90-0262173	Jerome	4204 Elit. St.	9	Marystown	ZB30 1VN
46-4306622	Brock	Ap #100-9421 Metus St.	46	Llandovery	88331
22-4950259	Kaseem	P.O. Box 334, 4042 Dis Avenue	41	Paredones	TE67 8GO
37-9024049	Eagan	8963 Quisque Av.	22	Novo Hamburgo	6732 MM
49-9416117	Chastity	P.O. Box 172, 204 A Street	38	Lublin	27922
74-6347410	Nicholas	P.O. Box 169, 7365 Metus St.	20	Monte San Pietrangeli	8005
74-6347410	Elvis	Ap #931-4733 Massa Ave	6	Ficarolo	973529
11-6371656	Fitzgerald	Ap #683-9978 Tortor Avenue	31	West Valley City	56110
74-6347410	Gail	Ap #495-6133 Accumsan Ave	21	Hannover	76204
17-3223513	Hiroko	454 Et St.	42	Sneek	1592
73-3358461	Micah	268-1124 Sodales St.	48	Alassio	45537
54-3525571	Dahlia	758-6992 Tortor. Street	30	Francavilla Fontana	4233
62-6138652	Yael	8652 Id, St.	30	Bulzi	79337
00-0651073	Thor	7123 Libero. Av.	50	Reus	15021
91-4724879	Jack	869-7866 Orci Rd.	32	Beverley	60-591
63-6658840	Lee	Ap #431-4588 At St.	12	Paradise	75275
49-9416117	Paki	180-334 Tincidunt, Ave	24	MalŽves-Sainte-Marie-Wastines	2320
55-6935035	Lewis	P.O. Box 409, 1052 Eget Rd.	41	Santander	9760 AK
38-6239730	Taylor	4147 Dui. Av.	16	Villers-la-Tour	3270
56-9679854	Burton	P.O. Box 519, 3710 Mauris Street	8	Matera	0697 JP
26-2106213	Berk	677 Feugiat. Avenue	40	Chiguayante	56661
89-0232531	Graiden	2038 Tincidunt Rd.	48	Poulseur	60310
38-5558539	Francesca	143-7317 Sed Road	45	Nashville	1985
47-0373803	Otto	P.O. Box 766, 6060 Eget St.	38	Drumheller	S2B 2Z4
68-1681959	Sybill	7519 Elit. Road	36	Glimes	44006
47-0373803	Emmanuel	748-8930 Quisque Road	41	Lac La Biche County	02666-076
23-7102043	Astra	Ap #437-1988 Egestas. Rd.	35	Sint-Pauwels	486361
\.


--
-- Data for Name: anggota; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.anggota (no_ktp, poin, level) FROM stdin;
91-2271079	9	gold
54-5414033	8	silver
09-3873358	3	gold
95-3869222	2	bronze
98-8557557	1	bronze
45-2666102	3	silver
62-6768332	1	silver
31-4951229	1	gold
74-9686420	10	bronze
85-6383011	7	gold
99-9092432	5	gold
53-1552795	1	silver
85-5621510	5	bronze
94-1012449	2	gold
05-8036652	5	bronze
88-4468470	2	gold
08-3828480	3	silver
80-1732128	7	gold
88-4363286	8	gold
80-3713705	2	silver
85-4332241	3	bronze
75-5784519	10	bronze
41-5923595	6	silver
22-4570463	2	gold
10-6765373	7	gold
39-2398085	2	gold
99-2895129	10	bronze
88-9339984	4	silver
28-4726627	5	gold
36-1995474	9	bronze
76-8189638	9	gold
58-9067754	1	bronze
35-2951411	7	gold
58-7751015	10	gold
99-1224681	7	gold
97-4104338	6	bronze
80-6546282	2	silver
65-2762150	5	bronze
91-8116990	7	silver
83-2480047	2	silver
00-4846838	4	bronze
87-7634375	1	bronze
14-0726643	1	silver
77-7148223	10	silver
28-7864139	10	silver
25-2116525	1	silver
24-7092125	7	bronze
72-6544899	8	silver
18-0943382	3	bronze
61-8938466	9	gold
88-1785178	8	silver
46-3695500	7	silver
68-1681959	7	bronze
31-5087250	8	bronze
76-4863780	1	silver
50-2730271	8	bronze
90-0262173	6	silver
47-0373803	5	silver
22-4950259	1	silver
23-7102043	7	gold
37-9024049	5	gold
73-3358461	2	bronze
50-6722733	5	bronze
21-9661851	2	gold
51-1435536	1	gold
05-7449820	7	bronze
89-0232531	6	gold
56-9679854	7	silver
55-6935035	7	bronze
31-1836523	6	bronze
74-6347410	8	bronze
11-6371656	7	bronze
63-6658840	2	gold
00-0651073	10	gold
03-8466469	8	silver
54-3525571	7	bronze
81-9341132	3	gold
54-8763454	4	bronze
91-4724879	5	bronze
17-3223513	3	bronze
38-5558539	5	bronze
49-9416117	2	silver
38-6239730	6	silver
29-2122920	6	gold
26-2106213	9	bronze
62-6138652	3	gold
25-3588974	5	gold
58-4832507	5	silver
71-5394236	5	bronze
46-4306622	2	gold
\.


--
-- Data for Name: barang; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.barang (id_barang, nama_item, warna, url_foto, kondisi, lama_penggunaan, no_ktp_penyewa) FROM stdin;
1	F150	yellow	A46ECFB3-A5AB-4B25-3B8F-0FC352D8A587	tristique ac, eleifend vitae, erat. Vivamus nisi.	6	28-7864139
2	Diamante	blue	ECCD1A6F-F29B-50A9-D9D9-227AC241F716	sed consequat auctor, nunc nulla	36	31-5087250
3	Grand Caravan	blue	8D5D2C2A-02E3-43FF-73F2-DBA222C2BFB8	rutrum, justo. Praesent luctus. Curabitur egestas nunc sed libero. Proin	28	31-5087250
4	F150	green	2D1E86A8-B911-9432-28B0-2D4596D8F400	tempor erat neque non	24	28-7864139
5	Wrangler	green	10EF96DD-7A8B-7944-DE11-CB2D57424170	commodo hendrerit.	21	31-5087250
6	911	orange	524BDB59-5688-A291-9502-0AEB835587EC	mi pede, nonummy ut, molestie in, tempus eu, ligula. Aenean	29	31-5087250
7	Legacy	yellow	7A6CD43B-F329-F259-0C9E-CCD4F5AF4DF5	tristique neque venenatis lacus. Etiam bibendum fermentum metus.	12	91-2271079
8	Grand Caravan	blue	4F3658AB-4B2D-E11A-15EF-50C3745AA0FB	adipiscing elit. Aliquam auctor, velit eget laoreet	10	47-0373803
9	Grand Cherokee	orange	C0757F2F-D395-6BAC-9CA5-AC9DC3066181	vulputate	40	55-6935035
10	TL	yellow	DAD7881E-D747-5861-6E70-26FFA5EB06FB	sit amet metus. Aliquam erat volutpat. Nulla facilisis. Suspendisse commodo	28	18-0943382
11	Legacy	orange	4AEAD47E-114E-0DA5-F7FE-334C63BF45AF	Morbi neque tellus, imperdiet non, vestibulum nec, euismod in,	34	31-1836523
12	Elantra	red	24EBDBF9-218E-FA7D-7600-AC017BAF9359	dictum sapien. Aenean massa. Integer vitae nibh. Donec est mauris,	14	18-0943382
13	Elantra	red	70FED310-43BC-F0C7-9AED-6B40B08D871E	ligula. Donec luctus aliquet odio. Etiam ligula tortor, dictum	6	31-1836523
14	Wrangler	violet	CBB6FAA4-D92A-3D2A-5BB9-A07D77045E1F	adipiscing fringilla, porttitor vulputate, posuere	8	18-0943382
15	Elantra	yellow	9C3CF626-0C85-7D46-A66C-5F5B80E7CDAA	eu eros. Nam consequat	39	18-0943382
16	Legacy	indigo	90F1FF3F-0851-A53B-7836-7B853ABC32B0	vitae velit	35	62-6768332
17	Pajero	red	0B435804-4BE8-746F-E5AA-7C8228C3303E	eu tempor	10	55-6935035
18	Envoy	violet	C8BCC339-62D0-8FF9-FAA0-ABFB02D7448D	ipsum. Curabitur consequat,	1	18-0943382
19	Ranger	blue	9FAD3BF5-12DD-ADD7-A411-304768D02580	vel, mauris. Integer sem elit, pharetra ut, pharetra	23	83-2480047
20	X6	yellow	749DE7F1-BC22-05C6-A3F5-FE0C9D30D6E2	ut cursus luctus, ipsum leo elementum sem, vitae	27	41-5923595
21	Legacy	indigo	C59F6E98-9446-BDC6-4C75-367326939425	nunc. In at pede. Cras	20	00-0651073
22	Express	green	C662EFB8-6E54-C1FC-20F0-C0E9BD96A941	Nullam enim. Sed nulla ante, iaculis nec, eleifend non,	29	88-9339984
23	Express 3500	violet	65896D56-7F6F-97EA-4B08-CAA32EF781A8	amet ornare lectus	14	53-1552795
24	Grand Caravan	red	49EB877A-928C-3C04-20ED-1DE04A4626F5	nisl.	39	91-2271079
25	Beetle	yellow	91CE42FD-DE7E-35B5-B590-723521FFD04D	primis in faucibus orci luctus et ultrices posuere cubilia	27	63-6658840
26	E-Class	orange	0647F445-1997-B8EE-155B-8E424405C050	adipiscing. Mauris molestie pharetra	39	63-6658840
27	Grand Caravan	yellow	53026D83-3A25-563F-D280-83FEFD49DDB7	eu, placerat eget, venenatis a, magna. Lorem ipsum dolor sit	36	85-5621510
28	F150	blue	8FEEB2BD-9477-07D1-44A1-151E0E570C7E	sociis	6	91-2271079
29	Grand Caravan	indigo	AD2C96D5-BFFD-B24C-F5B9-D4CD85F5EF8F	sem semper erat, in consectetuer ipsum nunc id enim.	19	81-9341132
30	968	blue	5067989F-AB48-87BC-A937-97B2481FB17D	Cras dolor dolor, tempus non, lacinia at, iaculis	16	26-2106213
31	F150	red	367957EE-CC37-4744-083B-FD57ECBF2687	tincidunt, neque vitae	10	99-2895129
32	Diamante	red	788E7C6A-6777-62AA-99FD-EBB2AC194572	hendrerit	14	14-0726643
33	XLR	orange	E30EF8B9-6535-2A80-4895-36D2ED160192	eros. Proin ultrices. Duis volutpat nunc	3	14-0726643
34	Dakota Club	blue	B18BF006-9A74-5AE1-2051-F3B09EDF97BF	Sed	25	25-2116525
35	Legacy	indigo	C91BC120-0C9A-4837-6682-0CE9FC9EC194	bibendum. Donec felis orci, adipiscing non, luctus sit	6	99-1224681
36	XLR	indigo	6A157FBB-7D96-3A3B-B632-3BF4883AF30D	Donec tempor, est ac	16	10-6765373
37	Yukon XL 2500	red	E6C433D5-84EE-7921-0A08-C81C45CF7319	consectetuer mauris	30	10-6765373
38	Yukon XL 2500	yellow	AE6D6456-E455-9F50-0B82-25A3F3136622	turpis. Nulla aliquet. Proin velit. Sed malesuada augue ut	2	35-2951411
39	Yukon XL 2500	orange	8838C1A9-D8C9-C75D-906E-A71E79FEA1E2	nec, imperdiet nec, leo. Morbi neque tellus, imperdiet non, vestibulum	27	22-4570463
40	Legacy	indigo	6BF3A00F-A8E7-1EA1-F337-0B5EC61EB556	varius ultrices, mauris ipsum porta elit, a feugiat tellus lorem	34	77-7148223
41	968	blue	5D53FC14-9B7C-0D0F-BB6C-953E7157AFFF	pede. Cras vulputate velit eu sem. Pellentesque	11	76-4863780
42	Pajero	orange	6F0C971A-F68F-CD05-EE0D-B0883AF1F551	pellentesque massa lobortis ultrices. Vivamus rhoncus. Donec est. Nunc ullamcorper,	22	00-0651073
43	Elantra	violet	CE08149E-9EC5-F7C7-3558-4AD0544172DA	dis parturient montes, nascetur ridiculus mus. Proin vel arcu	31	25-2116525
44	Legacy	violet	92456733-5335-C1EE-410F-D2CF18AF1F23	Donec feugiat metus sit amet ante. Vivamus	32	76-4863780
45	Grand Caravan	red	913C75C0-F7A2-DF7E-886F-20ECE7B13E1F	egestas	36	85-5621510
46	Legacy	violet	EAC9D0F3-4A85-73F2-F8A8-319068834E8E	sollicitudin commodo ipsum. Suspendisse	32	31-1836523
47	Boxster	green	CB63A143-F31A-3A36-39BA-EF54CBA166BE	aliquet diam. Sed	31	46-3695500
48	Grand Caravan	green	A951A39F-24E9-B36F-A7EC-71E4E308BAAA	aliquam arcu. Aliquam ultrices iaculis odio.	32	80-6546282
49	Elantra	blue	6BB8ACE2-141A-D3D9-72DD-3B74E4028735	scelerisque	7	85-5621510
50	Galant	orange	DB97E2B4-FB8D-DB20-A65D-691C55A6297B	ut dolor dapibus gravida. Aliquam tincidunt, nunc ac mattis	7	23-7102043
51	Elantra	blue	9C21DFBB-C0C1-0668-CA44-850BF2D6E1F8	consequat purus. Maecenas libero est, congue a, aliquet vel, vulputate	20	87-7634375
52	Beetle	red	CB32B2A9-6802-2030-8D33-B9426764C0A1	eu eros. Nam consequat	28	74-6347410
53	Beetle	orange	926000CA-5E01-2141-5E33-C9A51A4F4096	metus. Aliquam erat volutpat. Nulla facilisis.	10	85-5621510
54	Envoy	yellow	24D439C6-0BF5-5756-93EA-0CFCA7FC744B	molestie pharetra nibh. Aliquam ornare, libero	29	29-2122920
55	Elantra	green	E9540016-D11F-B98D-634A-71A104CBB8D2	ante. Nunc mauris sapien,	34	29-2122920
56	E-Class	orange	2CE7D7BC-FDEF-5068-8193-0AD876365D06	et	5	29-2122920
57	Diamante	orange	A8752F01-6EDB-FCA3-17C9-629DFDED2338	molestie tortor nibh sit	13	03-8466469
58	Envoy	blue	7BA97D39-9432-7151-8315-3E64F4BD9029	arcu. Vestibulum ante ipsum primis	28	62-6138652
59	Legacy	green	9DB1E7BB-56A6-1026-F4D9-82B81EE48B17	sit amet orci.	4	03-8466469
60	E-Class	blue	8777BF85-54E5-66DF-B384-3A33794BFCB0	neque venenatis lacus. Etiam	26	49-9416117
61	E-Class	green	BA4F6F32-F0B7-5B6E-F85B-53AE6BEF603A	eu, odio. Phasellus at augue id ante dictum cursus.	25	54-3525571
62	E-Class	indigo	C2322933-F5D7-BA3E-7937-EB0B599050F6	in	6	11-6371656
63	Legacy	blue	189B6F91-F422-5AF7-4CE9-18063CB91953	dictum cursus. Nunc mauris elit,	37	03-8466469
64	Beetle	blue	A1F789B9-5F36-4726-C552-A67E93A672E9	dictum ultricies ligula. Nullam enim. Sed nulla ante, iaculis nec,	29	00-0651073
65	Protege	yellow	3A708D26-397C-C4A0-9C4D-F919DA059830	nec urna et arcu imperdiet ullamcorper.	4	29-2122920
66	Legacy	green	E52F263A-8540-EB3C-9A63-127D7631C540	at risus. Nunc ac sem ut dolor dapibus gravida. Aliquam	4	11-6371656
67	E-Class	blue	DC46A201-8416-7A76-D279-A0127A8AF3DE	dapibus rutrum, justo. Praesent luctus. Curabitur egestas nunc sed libero.	14	72-6544899
68	Express	indigo	6AB61EB3-CDAF-4EDC-6088-9BE93305BCBB	sed, facilisis vitae, orci. Phasellus dapibus quam quis	28	74-9686420
69	Pajero	orange	7B1214CD-4159-E147-FE93-5C3A1ECD9777	Cras convallis convallis dolor. Quisque tincidunt pede ac urna.	21	53-1552795
70	Pajero	indigo	ED721AD2-93ED-178F-73E5-D8E7C06C5185	sit amet risus. Donec egestas. Aliquam nec enim.	19	72-6544899
71	Express	indigo	72C2B575-0393-EE60-05FA-3E6C8032225C	enim, condimentum eget,	18	53-1552795
72	Pajero	red	942AD544-4509-8FF0-3DF2-4F06194CA441	eros.	30	72-6544899
73	Express	violet	5D524517-C700-45A4-A748-06C8CFFA6343	Donec porttitor tellus non magna. Nam ligula elit, pretium et,	17	47-0373803
74	Pajero	yellow	B4F262F2-D0B8-23ED-A36B-340EDF4EA5B5	tempus eu, ligula. Aenean	8	37-9024049
75	Elantra	orange	9EAF18C1-88E7-60DE-83EB-A1B04EFB62DB	eu,	19	85-4332241
76	G35	red	058CA740-24B8-8B49-4992-B44F4E487375	non justo. Proin	20	61-8938466
77	G35	violet	0DC1F075-F375-11CC-38DC-C66023BB5404	Phasellus dapibus quam	28	11-6371656
78	G35	indigo	9FAA15EA-E1AC-46B9-BC64-7DD408EDA32B	tellus sem	2	58-7751015
79	Express	green	A251F057-7B1F-307C-DE2C-02A909B03B5C	Ut sagittis lobortis mauris. Suspendisse aliquet molestie tellus. Aenean	4	88-1785178
80	Galant	green	F772D37E-59A6-C848-22C9-A38B51A753AB	sagittis semper. Nam tempor diam dictum	19	08-3828480
81	Express	orange	13C33888-AD3A-3BB7-FDC6-487A47B8A91D	mus. Proin vel nisl. Quisque fringilla	29	88-4468470
82	Diamante	violet	811DF570-B97C-5B5B-FC1F-71BF2B90F920	ac tellus. Suspendisse	10	24-7092125
83	Protege	violet	ACC70A45-2468-4352-FF35-F45DDDEB4359	massa. Suspendisse eleifend. Cras sed	3	58-9067754
84	Express	indigo	F14A46A4-6FE5-7139-1493-6BDA031DA696	per inceptos hymenaeos. Mauris	12	50-6722733
85	Diamante	red	2028897F-54C5-D6E8-879A-A003041BCDE0	tincidunt vehicula risus.	11	88-4363286
86	Protege	violet	59FC6716-8C45-FDC5-07BD-9EB4F4FFE7FE	sociis natoque penatibus et magnis dis	8	76-8189638
87	Diamante	violet	D7F63424-E7AA-E0AB-FCD2-B9E6CF3F8FE5	in, hendrerit consectetuer,	9	73-3358461
88	Protege	green	BFE7AA6E-F5C7-7FB1-F86F-03463C6DC5C0	accumsan sed, facilisis vitae, orci. Phasellus dapibus	40	98-8557557
89	Protege	red	72F33852-6BFE-AFBF-A035-4C307E20423F	neque non quam. Pellentesque habitant morbi	16	05-8036652
90	Diamante	green	E62DBD63-115F-41B0-CFAD-DED8AA1A2171	interdum feugiat. Sed nec metus facilisis lorem	17	68-1681959
91	Elantra	blue	16B8BA2D-D2FE-33E5-67C2-9F2036863012	lacinia orci,	38	51-1435536
92	Legacy	blue	6587AC72-F262-B9F9-C0B5-3B8BBFF34C3D	tempus scelerisque, lorem ipsum sodales	8	17-3223513
93	Legacy	orange	13005CFB-6E8E-13E0-8536-377E9E086C28	nec	9	68-1681959
94	Protege	red	AC2B7C2E-73A5-F26E-AFF9-1D2415E0E8AE	egestas a, dui. Cras pellentesque. Sed dictum. Proin	2	38-5558539
95	Elantra	yellow	3B4254D0-D816-A4BC-874A-AC593BE99754	Nulla facilisi. Sed neque. Sed eget lacus. Mauris	12	68-1681959
96	Elantra	yellow	E298F3E1-8DCC-040D-5216-0D5504172856	odio. Etiam ligula tortor, dictum eu, placerat eget, venenatis	23	80-1732128
97	Pajero	red	66178BE1-B725-605B-5B81-6CAD84B20C98	et, euismod et, commodo at, libero. Morbi accumsan laoreet	20	85-6383011
98	Elantra	blue	6563C11A-5456-AC2F-5D55-5F409D2A3637	Cum sociis natoque penatibus et magnis dis	6	36-1995474
99	Express	yellow	5A5AC8F5-D55D-9FF2-D568-90B3EFCCC864	malesuada	15	28-7864139
100	Diamante	blue	94403985-8C25-5AB4-A567-A0EB5A3118E4	nulla. In tincidunt congue turpis. In condimentum. Donec at arcu.	19	94-1012449
\.


--
-- Data for Name: barang_dikembalikan; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.barang_dikembalikan (no_resi, no_urut, id_barang) FROM stdin;
1000	1	1
1001	2	2
1002	3	3
1003	4	4
1004	5	5
1005	6	6
1006	7	7
1007	8	8
1008	9	9
1009	10	10
1010	11	11
1011	12	12
1012	13	13
1013	14	14
1014	15	15
1015	16	16
1016	17	17
1017	18	18
1018	19	19
1019	20	20
1010	21	21
1005	22	22
1017	23	23
1004	24	24
1006	25	25
1013	26	26
1002	27	27
1011	28	28
1019	29	29
1012	30	30
1008	31	31
1009	32	32
1005	33	33
1014	34	34
1016	35	35
1007	36	36
1019	37	37
1012	38	38
1017	39	39
1011	40	40
\.


--
-- Data for Name: barang_dikirim; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.barang_dikirim (no_resi, no_urut, id_barang, tanggal_review, review) FROM stdin;
1000	0	1	2019-02-16	barang diterima dengan baik
1001	1	2	2019-02-17	barang bagus. trims
1002	2	3	2019-03-07	sukak sama barangnya
1003	3	4	2019-04-10	barang tidak sesuai harapan
1004	4	5	2019-01-15	barangnya lucuk
1005	5	6	2019-02-11	beda sama yang digambar
1006	6	7	2019-03-15	recommended banget
1007	7	8	2019-02-19	pengiriman cepat
1008	8	9	2019-03-23	bakal order disini terus
1009	9	10	2019-02-27	sesuai ekspektasi
1010	10	11	2019-02-26	not bad
1011	11	12	2019-04-18	ada harga ada barang
1012	12	13	2019-03-17	tidak terlalu buruk
1013	13	14	2019-02-24	sesuai ekspektasi
1014	14	15	2019-01-19	barangnya bagus banget, makasih ya
1015	15	16	2019-02-18	barang standar
1016	16	17	2019-02-16	barangnya ada yg penyok dikit
1017	17	18	2019-04-15	warnanya tidak sesuai pesanan
1018	18	19	2019-03-14	not bad lah dengan harga segitu
1019	19	20	2019-02-12	ga ada kartu garansinya
1004	20	21	2019-02-25	aku suka sama barangnya
1002	21	22	2019-03-23	kenapa yang datang hanya 1?
1007	22	23	2019-01-24	kirain besar, taunya kecil
1008	23	24	2019-02-16	barang original
1010	24	25	2019-02-23	ga recommended tokonya
1011	25	26	2019-03-22	kok barangnya beda sama digambar?
1012	26	27	2019-02-14	tidak sesuai ekspektasi
1014	27	28	2019-02-25	menyesal beli disini
1016	28	29	2019-03-23	sesuai sama gambar. Makasih
1018	29	30	2019-01-24	sama kaya pembelian sebelumnya
1019	30	31	2019-02-16	recommended
1004	31	32	2019-02-23	tidak mengecewakan
1002	32	33	2019-03-22	barangnya cepat sampai
1007	33	34	2019-02-14	barang ada yang cacat
1008	34	35	2019-02-25	kenapa ga dikonfirm dulu kalau warnanya beda?
1009	35	36	2019-03-23	bagus dan aman packingnya
1011	36	37	2019-01-24	biasa aja
1013	37	38	2019-02-16	barangnya bagus, tapi ada lecet sedikit
1015	38	39	2019-02-23	kirain buatan vietnam, ternyata thailand
1016	39	40	2019-03-22	barang original
1018	40	41	2019-02-14	barang seperti ori padahal kw
\.


--
-- Data for Name: barang_pesanan; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.barang_pesanan (id_pemesanan, no_urut, id_barang, tanggal_sewa, lama_sewa, tanggal_kembali, status) FROM stdin;
P-72048063	1	62	2018-09-10	24	\N	sedang_disiapkan
P-21204315	2	63	2018-12-20	48	2019-03-15	sedang_dikirim
P-92190012	3	26	2019-02-12	27	2018-12-07	sedang_disiapkan
P-94366340	4	66	2018-12-25	6	\N	sudah_dikembalikan
P-56787860	5	53	2018-08-23	27	\N	sedang_disiapkan
P-57268075	6	77	2019-01-29	13	2018-12-09	sudah_dikembalikan
P-58857087	7	30	2018-08-01	39	2018-10-29	sedang_dikirim
P-67410985	8	49	2018-12-31	43	2019-02-12	dalam_masa_sewa
P-94366340	9	61	2019-03-01	5	2018-10-15	sedang_dikirim
P-72048063	10	83	2018-09-13	19	\N	sedang_dikirim
P-14876776	11	5	2019-02-08	7	2018-12-12	menunggu_pembayaran
P-13360628	12	45	2018-08-16	8	2018-12-21	dalam_masa_sewa
P-21204315	13	72	2018-10-31	44	\N	batal
P-66010035	14	59	2018-08-27	20	2018-12-28	dalam_masa_sewa
P-92190012	15	22	2018-06-27	12	\N	sudah_dikembalikan
P-96070916	16	14	2018-07-23	8	\N	sedang_dikirim
P-66010035	17	31	2018-07-29	8	\N	dalam_masa_sewa
P-58960673	18	50	2018-05-31	44	2018-10-11	sudah_dikembalikan
P-63281370	19	7	2018-08-31	21	\N	dalam_masa_sewa
P-30159675	20	96	2018-04-23	21	\N	dalam_masa_sewa
P-99526739	21	27	2018-10-19	30	2019-02-19	dalam_masa_sewa
P-21574182	22	28	2018-05-09	12	\N	sedang_dikonfirmasi
P-03203429	23	19	2019-02-15	19	2019-01-22	sedang_disiapkan
P-73683953	24	44	2019-03-08	38	\N	menunggu_pembayaran
P-94366340	25	21	2018-07-15	46	\N	sedang_dikonfirmasi
P-30159675	26	91	2018-07-03	29	\N	sedang_disiapkan
P-44525113	27	66	2018-09-12	5	\N	sedang_dikonfirmasi
P-37173868	28	48	2018-11-23	28	\N	sedang_disiapkan
P-67410985	29	69	2019-04-05	50	2019-01-13	batal
P-21574182	30	24	2018-09-25	47	2019-04-07	sedang_dikirim
P-96070916	31	94	2018-08-25	20	2018-11-01	batal
P-14249818	32	6	2018-12-11	31	\N	sedang_dikonfirmasi
P-67369244	33	12	2019-03-04	11	2019-01-15	dalam_masa_sewa
P-14876776	34	88	2018-06-06	27	\N	sudah_dikembalikan
P-03203429	35	23	2018-05-15	50	2018-12-20	dalam_masa_sewa
P-56787860	36	33	2018-07-25	2	\N	menunggu_pembayaran
P-79625429	37	100	2018-08-23	27	\N	menunggu_pembayaran
P-21146974	38	17	2019-04-12	31	\N	dalam_masa_sewa
P-37173868	39	60	2019-03-23	37	\N	dalam_masa_sewa
P-14835241	40	43	2018-07-17	42	2019-03-30	dalam_masa_sewa
P-88589615	41	88	2018-06-29	6	\N	sudah_dikembalikan
P-37173868	42	34	2018-08-20	48	\N	dalam_masa_sewa
P-94343818	43	34	2018-08-16	49	2019-03-06	batal
P-21204315	44	47	2018-11-25	20	2019-02-11	dalam_masa_sewa
P-14876776	45	34	2019-03-04	50	2018-12-24	sedang_dikirim
P-92190012	46	35	2018-08-12	39	\N	sudah_dikembalikan
P-13749887	47	29	2018-10-11	47	2019-03-10	sedang_dikonfirmasi
P-21204315	48	53	2018-10-26	21	2019-04-02	dalam_masa_sewa
P-31282248	49	94	2018-09-07	48	2019-01-21	menunggu_pembayaran
P-56787860	50	86	2018-07-21	5	2019-01-25	sedang_dikirim
P-07541032	51	32	2018-06-05	24	2018-11-30	sudah_dikembalikan
P-42642764	52	71	2018-05-03	10	\N	dalam_masa_sewa
P-42642764	53	31	2018-06-20	37	\N	sudah_dikembalikan
P-57268075	54	52	2018-10-08	12	2018-11-18	sedang_dikirim
P-31282248	55	47	2019-03-07	6	2019-03-20	sedang_disiapkan
P-21574182	56	14	2019-03-15	37	2019-02-02	sedang_dikonfirmasi
P-99526739	57	58	2018-09-21	8	2018-12-09	sedang_disiapkan
P-88589615	58	19	2018-05-01	28	\N	menunggu_pembayaran
P-58857087	59	31	2018-10-10	21	2019-03-31	sudah_dikembalikan
P-09274864	60	22	2018-12-28	3	\N	sedang_dikirim
P-79625429	61	39	2018-09-14	21	\N	batal
P-24323334	62	85	2018-09-23	2	2018-10-14	sedang_dikonfirmasi
P-57268075	63	5	2018-11-22	48	\N	sudah_dikembalikan
P-63281370	64	10	2018-07-29	22	\N	sudah_dikembalikan
P-67410985	65	61	2018-05-29	13	\N	batal
P-58960673	66	69	2018-10-07	50	\N	sedang_dikonfirmasi
P-30159675	67	63	2018-05-25	19	\N	sedang_dikirim
P-03203429	68	49	2018-09-28	11	\N	sedang_disiapkan
P-94366340	69	38	2018-07-04	30	\N	sedang_dikirim
P-42642764	70	20	2019-01-16	16	\N	sudah_dikembalikan
P-99526739	71	71	2018-04-22	21	\N	sedang_dikonfirmasi
P-21081111	72	56	2018-10-17	36	\N	batal
P-59252325	73	46	2018-07-27	41	\N	sedang_dikonfirmasi
P-21146974	74	85	2019-02-11	27	\N	sedang_dikirim
P-21574182	75	15	2018-07-15	16	2019-01-07	batal
P-92190012	76	93	2019-04-12	29	2019-02-21	dalam_masa_sewa
P-05263928	77	61	2018-05-03	49	\N	menunggu_pembayaran
P-03203429	78	26	2018-05-11	26	2018-12-25	batal
P-01763785	79	67	2018-05-30	29	2019-02-21	sedang_dikirim
P-37173868	80	85	2018-10-16	42	\N	batal
P-48637492	81	30	2018-11-11	48	\N	sedang_dikonfirmasi
P-21146974	82	66	2018-08-28	13	2019-01-26	sedang_dikirim
P-28956503	83	56	2019-03-18	3	2018-10-08	dalam_masa_sewa
P-50389624	84	7	2018-11-28	14	2018-12-20	sudah_dikembalikan
P-24323334	85	9	2019-01-20	41	\N	dalam_masa_sewa
P-96070916	86	90	2018-05-16	21	\N	sedang_dikonfirmasi
P-92190012	87	21	2018-05-21	38	2019-02-12	batal
P-83632875	88	85	2018-09-26	42	2019-01-03	sudah_dikembalikan
P-58960673	89	54	2018-06-02	43	\N	batal
P-59252325	90	49	2018-08-03	5	2019-04-11	sedang_disiapkan
P-96070916	91	94	2019-04-11	31	\N	sedang_dikirim
P-58960673	92	32	2018-09-09	8	2018-12-25	dalam_masa_sewa
P-92190012	93	62	2018-07-24	20	\N	sudah_dikembalikan
P-21146974	94	16	2018-05-16	24	\N	sedang_dikonfirmasi
P-01763785	95	33	2018-11-05	20	\N	sedang_dikonfirmasi
P-66010035	96	71	2019-03-30	7	\N	menunggu_pembayaran
P-50389624	97	40	2018-09-19	17	\N	menunggu_pembayaran
P-15970375	98	67	2018-04-15	29	\N	sedang_disiapkan
P-31282248	99	36	2018-05-06	27	2019-02-03	sedang_disiapkan
P-14249818	100	97	2019-01-23	18	\N	menunggu_pembayaran
\.


--
-- Data for Name: chat; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.chat (id, pesan, date_time, no_ktp_anggota, no_ktp_admin) FROM stdin;
IUQ43PHP9XP	nisl ut	2018-09-18 00:00:00	95-3869222	46-4222968
YXI76CDT4VW	fames ac turpis egestas.	2018-09-18 00:00:00	98-8557557	46-4222968
NZU20TBJ6TH	est arcu ac orci. Ut	2018-09-18 00:00:00	45-2666102	61-5163734
JBX31XKU7DI	mauris laoreet	2018-09-18 00:00:00	62-6768332	80-5342780
JHL60BJD7MA	velit nec nisi	2018-09-18 00:00:00	98-8557557	46-4222968
FRU51YBQ5WN	eu, eleifend nec,	2020-01-09 00:00:00	31-4951229	91-8332192
MOV37SOZ9PD	convallis tortor risus	2018-09-18 00:00:00	09-3873358	41-1743563
MVL97NHS8EZ	id pretium iaculis	2018-09-18 00:00:00	98-8557557	46-4222968
UXW79NUC5JP	sit amet turpis	2018-09-18 00:00:00	62-6768332	61-5163734
VTS74EXQ4SC	id nulla ultrices	2018-09-18 00:00:00	62-6768332	61-5163734
WEH00ITV1MP	sapien dignissim vestibulum vestibulum	2018-09-18 00:00:00	45-2666102	61-5163734
XXZ47WCQ4EC	ut volutpat	2018-09-18 00:00:00	45-2666102	61-5163734
AMK02NTV0KZ	erat vestibulum sed	2018-09-08 00:00:00	74-9686420	36-9622643
KJF90LCO8UX	posuere cubilia curae donec	2018-09-18 00:00:00	45-2666102	61-5163734
BTC13IDI5PT	massa volutpat	2020-01-09 00:00:00	31-4951229	91-8332192
DTJ21EOA7AV	suspendisse potenti	2018-09-08 00:00:00	74-9686420	36-9622643
DZW37MNW0OD	mauris viverra diam	2020-01-09 00:00:00	31-4951229	91-8332192
GHM81OBM2AM	phasellus id sapien in	2019-04-01 00:00:00	91-2271079	41-1743563
LFD40FXY6OT	odio condimentum id	2018-09-08 00:00:00	74-9686420	36-9622643
PIV29FHW4FM	nec euismod scelerisque	2018-09-08 00:00:00	74-9686420	36-9622643
KTC83PHW1VJ	id luctus	2018-09-18 00:00:00	62-6768332	80-5342780
PHO37JAS8AI	turpis enim	2018-09-18 00:00:00	62-6768332	29-6736736
PII74XSQ3BP	rutrum ac lobortis	2018-09-18 00:00:00	62-6768332	80-5342780
POL02AJK8PY	id sapien in	2019-04-01 00:00:00	91-2271079	41-1743563
SBW95QFY8JC	aenean fermentum	2017-09-07 00:00:00	85-6383011	91-8332192
TGN41EGF3YF	ut volutpat sapien arcu	2018-09-08 00:00:00	74-9686420	36-9622643
TZS91FCO6CZ	eu tincidunt	2019-04-01 00:00:00	91-2271079	41-1743563
UUR48OHW1AT	hac habitasse platea dictumst	2019-04-01 00:00:00	91-2271079	41-1743563
YTS81ASD0AQ	eu tincidunt	2018-09-18 00:00:00	62-6768332	29-6736736
VWI49QJZ2YQ	erat fermentum justo nec	2020-01-09 00:00:00	31-4951229	91-8332192
WDD41KFQ7OF	viverra diam	2020-01-09 00:00:00	31-4951229	91-8332192
HFK55SBO0BG	consectetuer adipiscing	2017-09-07 00:00:00	85-6383011	91-8332192
JBE67CYK2EC	justo pellentesque viverra	2017-01-07 00:00:00	99-9092432	91-8332192
JLF80RWC1MS	tempus vel pede	2015-07-08 00:00:00	53-1552795	61-5163734
LWI27KYU1SH	lorem ipsum dolor	2015-07-08 00:00:00	53-1552795	61-5163734
OLO91TPI7FD	consectetuer adipiscing elit proin	2017-09-07 00:00:00	85-6383011	91-8332192
ACG54YGX0HO	est risus auctor	2015-07-08 00:00:00	53-1552795	61-5163734
ANP71XGN3XF	luctus et	2019-01-08 00:00:00	85-5621510	29-6736736
BHC50XES3VP	venenatis tristique	2017-01-07 00:00:00	99-9092432	06-9997319
CCL18DTB1BW	pede morbi porttitor	2017-09-07 00:00:00	85-6383011	17-1240312
CRX81XHD1LW	est lacinia	2015-07-08 00:00:00	53-1552795	61-5163734
DFR63BAZ9ZF	vel augue vestibulum	2017-01-07 00:00:00	99-9092432	06-9997319
DOA94IDW5CQ	quam fringilla	2017-01-07 00:00:00	99-9092432	06-9997319
EJJ40FCZ7WB	luctus cum sociis	2017-01-07 00:00:00	99-9092432	06-9997319
HCB25XSG7SZ	amet diam in magna	2019-01-08 00:00:00	85-5621510	29-6736736
SXL35DVB6ZV	tortor sollicitudin mi sit	2017-09-07 00:00:00	85-6383011	91-8332192
SYU24JHK7TK	ultrices vel	2019-01-08 00:00:00	85-5621510	29-6736736
SZO52HTE6YL	mus vivamus vestibulum	2019-01-08 00:00:00	85-5621510	29-6736736
UGB07RWD0IK	enim in	2019-01-08 00:00:00	85-5621510	29-6736736
ZYT98CPG5JA	dolor quis	2017-09-07 00:00:00	85-6383011	91-8332192
\.


--
-- Data for Name: info_barang_level; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.info_barang_level (id_barang, nama_level, harga_sewa, porsi_royalti) FROM stdin;
1	bronze	20000	1000
2	bronze	20000	1000
3	bronze	20000	1000
4	bronze	20000	1000
5	bronze	20000	1000
6	bronze	20000	1000
7	bronze	20000	1000
8	bronze	20000	1000
9	bronze	20000	1000
10	bronze	20000	1000
11	bronze	20000	1000
12	bronze	20000	1000
13	bronze	20000	1000
14	bronze	20000	1000
15	bronze	20000	1000
16	bronze	20000	1000
17	bronze	20000	1000
18	bronze	20000	1000
19	bronze	20000	1000
20	bronze	20000	1000
21	bronze	20000	1000
22	bronze	20000	1000
23	bronze	20000	1000
24	bronze	20000	1000
25	bronze	20000	1000
26	bronze	20000	1000
27	bronze	20000	1000
28	bronze	20000	1000
29	bronze	20000	1000
30	bronze	20000	1000
31	bronze	20000	1000
32	bronze	20000	1000
33	bronze	20000	1000
34	bronze	20000	1000
35	bronze	20000	1000
36	bronze	20000	1000
37	bronze	20000	1000
38	bronze	20000	1000
39	bronze	20000	1000
40	bronze	20000	1000
41	bronze	20000	1000
42	bronze	20000	1000
43	bronze	20000	1000
44	bronze	20000	1000
45	bronze	20000	1000
46	bronze	20000	1000
47	bronze	20000	1000
48	bronze	20000	1000
49	bronze	20000	1000
50	bronze	20000	1000
51	bronze	20000	1000
52	bronze	20000	1000
53	bronze	20000	1000
54	bronze	20000	1000
55	bronze	20000	1000
56	bronze	20000	1000
57	bronze	20000	1000
58	bronze	20000	1000
59	bronze	20000	1000
60	bronze	20000	1000
61	bronze	20000	1000
62	bronze	20000	1000
63	bronze	20000	1000
64	bronze	20000	1000
65	bronze	20000	1000
66	bronze	20000	1000
67	bronze	20000	1000
68	bronze	20000	1000
69	bronze	20000	1000
70	bronze	20000	1000
71	bronze	20000	1000
72	bronze	20000	1000
73	bronze	20000	1000
74	bronze	20000	1000
75	bronze	20000	1000
76	bronze	20000	1000
77	bronze	20000	1000
78	bronze	20000	1000
79	bronze	20000	1000
80	bronze	20000	1000
81	bronze	20000	1000
82	bronze	20000	1000
83	bronze	20000	1000
84	bronze	20000	1000
85	bronze	20000	1000
86	bronze	20000	1000
87	bronze	20000	1000
88	bronze	20000	1000
89	bronze	20000	1000
90	bronze	20000	1000
91	bronze	20000	1000
92	bronze	20000	1000
93	bronze	20000	1000
94	bronze	20000	1000
95	bronze	20000	1000
96	bronze	20000	1000
97	bronze	20000	1000
98	bronze	20000	1000
99	bronze	20000	1000
100	bronze	20000	1000
1	silver	15000	1500
2	silver	15000	1500
3	silver	15000	1500
4	silver	15000	1500
5	silver	15000	1500
6	silver	15000	1500
7	silver	15000	1500
8	silver	15000	1500
9	silver	15000	1500
10	silver	15000	1500
11	silver	15000	1500
12	silver	15000	1500
13	silver	15000	1500
14	silver	15000	1500
15	silver	15000	1500
16	silver	15000	1500
17	silver	15000	1500
18	silver	15000	1500
19	silver	15000	1500
20	silver	15000	1500
21	silver	15000	1500
22	silver	15000	1500
23	silver	15000	1500
24	silver	15000	1500
25	silver	15000	1500
26	silver	15000	1500
27	silver	15000	1500
28	silver	15000	1500
29	silver	15000	1500
30	silver	15000	1500
31	silver	15000	1500
32	silver	15000	1500
33	silver	15000	1500
34	silver	15000	1500
35	silver	15000	1500
36	silver	15000	1500
37	silver	15000	1500
38	silver	15000	1500
39	silver	15000	1500
40	silver	15000	1500
41	silver	15000	1500
42	silver	15000	1500
43	silver	15000	1500
44	silver	15000	1500
45	silver	15000	1500
46	silver	15000	1500
47	silver	15000	1500
48	silver	15000	1500
49	silver	15000	1500
50	silver	15000	1500
51	silver	15000	1500
52	silver	15000	1500
53	silver	15000	1500
54	silver	15000	1500
55	silver	15000	1500
56	silver	15000	1500
57	silver	15000	1500
58	silver	15000	1500
59	silver	15000	1500
60	silver	15000	1500
61	silver	15000	1500
62	silver	15000	1500
63	silver	15000	1500
64	silver	15000	1500
65	silver	15000	1500
66	silver	15000	1500
67	silver	15000	1500
68	silver	15000	1500
69	silver	15000	1500
70	silver	15000	1500
71	silver	15000	1500
72	silver	15000	1500
73	silver	15000	1500
74	silver	15000	1500
75	silver	15000	1500
76	silver	15000	1500
77	silver	15000	1500
78	silver	15000	1500
79	silver	15000	1500
80	silver	15000	1500
81	silver	15000	1500
82	silver	15000	1500
83	silver	15000	1500
84	silver	15000	1500
85	silver	15000	1500
86	silver	15000	1500
87	silver	15000	1500
88	silver	15000	1500
89	silver	15000	1500
90	silver	15000	1500
91	silver	15000	1500
92	silver	15000	1500
93	silver	15000	1500
94	silver	15000	1500
95	silver	15000	1500
96	silver	15000	1500
97	silver	15000	1500
98	silver	15000	1500
99	silver	15000	1500
100	silver	15000	1500
1	gold	10000	1500
2	gold	10000	1500
3	gold	10000	1500
4	gold	10000	1500
5	gold	10000	1500
6	gold	10000	1500
7	gold	10000	1500
8	gold	10000	1500
9	gold	10000	1500
10	gold	10000	1500
11	gold	10000	1500
12	gold	10000	1500
13	gold	10000	1500
14	gold	10000	1500
15	gold	10000	1500
16	gold	10000	1500
17	gold	10000	1500
18	gold	10000	1500
19	gold	10000	1500
20	gold	10000	1500
21	gold	10000	1500
22	gold	10000	1500
23	gold	10000	1500
24	gold	10000	1500
25	gold	10000	1500
26	gold	10000	1500
27	gold	10000	1500
28	gold	10000	1500
29	gold	10000	1500
30	gold	10000	1500
31	gold	10000	1500
32	gold	10000	1500
33	gold	10000	1500
34	gold	10000	1500
35	gold	10000	1500
36	gold	10000	1500
37	gold	10000	1500
38	gold	10000	1500
39	gold	10000	1500
40	gold	10000	1500
41	gold	10000	1500
42	gold	10000	1500
43	gold	10000	1500
44	gold	10000	1500
45	gold	10000	1500
46	gold	10000	1500
47	gold	10000	1500
48	gold	10000	1500
49	gold	10000	1500
50	gold	10000	1500
51	gold	10000	1500
52	gold	10000	1500
53	gold	10000	1500
54	gold	10000	1500
55	gold	10000	1500
56	gold	10000	1500
57	gold	10000	1500
58	gold	10000	1500
59	gold	10000	1500
60	gold	10000	1500
61	gold	10000	1500
62	gold	10000	1500
63	gold	10000	1500
64	gold	10000	1500
65	gold	10000	1500
66	gold	10000	1500
67	gold	10000	1500
68	gold	10000	1500
69	gold	10000	1500
70	gold	10000	1500
71	gold	10000	1500
72	gold	10000	1500
73	gold	10000	1500
74	gold	10000	1500
75	gold	10000	1500
76	gold	10000	1500
77	gold	10000	1500
78	gold	10000	1500
79	gold	10000	1500
80	gold	10000	1500
81	gold	10000	1500
82	gold	10000	1500
83	gold	10000	1500
84	gold	10000	1500
85	gold	10000	1500
86	gold	10000	1500
87	gold	10000	1500
88	gold	10000	1500
89	gold	10000	1500
90	gold	10000	1500
91	gold	10000	1500
92	gold	10000	1500
93	gold	10000	1500
94	gold	10000	1500
95	gold	10000	1500
96	gold	10000	1500
97	gold	10000	1500
98	gold	10000	1500
99	gold	10000	1500
100	gold	10000	1500
\.


--
-- Data for Name: item; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.item (nama, deskripsi, usia_dari, usia_sampai, bahan) FROM stdin;
Diamante	dolor vel est donec odio justo sollicitudin ut suscipit a feugiat et eros	7	7	Metal
Legacy	tincidunt lacus at velit vivamus vel nulla eget eros elementum pellentesque quisque porta volutpat	7	11	Ruby
Grand Caravan	sapien urna pretium nisl ut volutpat sapien arcu sed augue aliquam erat volutpat in congue etiam justo	5	9	Ruby
Yukon XL 2500	rutrum neque aenean auctor gravida sem praesent id massa id nisl venenatis lacinia	5	11	Ruby
Elantra	faucibus orci luctus et ultrices posuere cubilia curae duis faucibus accumsan odio curabitur	6	12	Metal
F150	massa quis augue luctus tincidunt nulla mollis molestie lorem quisque ut erat curabitur gravida nisi at nibh in	7	8	Gold
Express	lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat lectus	7	8	Plastic
Pajero	donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna	5	11	Rubber
Ranger	maecenas pulvinar lobortis est phasellus sit amet erat nulla tempus vivamus in felis eu sapien cursus	5	10	Plastic
Wrangler	a feugiat et eros vestibulum ac est lacinia nisi venenatis tristique fusce congue diam	6	8	Gold
TL	et magnis dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque	6	10	Metal
911	sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus etiam vel augue	6	7	Gold
Grand Cherokee	vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat	7	10	Ruby
Envoy	adipiscing lorem vitae mattis nibh ligula nec sem duis aliquam convallis nunc proin at turpis	6	12	Gold
Express 3500	velit nec nisi vulputate nonummy maecenas tincidunt lacus at velit	5	9	Gold
E-Class	proin risus praesent lectus vestibulum quam sapien varius ut blandit non interdum in ante vestibulum ante ipsum	5	7	Ruby
Beetle	nulla elit ac nulla sed vel enim sit amet nunc viverra dapibus nulla suscipit ligula	5	8	Plastic
X6	enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin interdum mauris non ligula pellentesque ultrices phasellus id sapien	6	8	Ruby
968	sapien urna pretium nisl ut volutpat sapien arcu sed augue aliquam erat volutpat in congue etiam justo	6	8	Ruby
XLR	libero non mattis pulvinar nulla pede ullamcorper augue a suscipit nulla elit ac nulla sed vel enim	6	12	Wood
Dakota Club	morbi non quam nec dui luctus rutrum nulla tellus in sagittis dui vel nisl duis ac	7	12	Rubber
Boxster	quam turpis adipiscing lorem vitae mattis nibh ligula nec sem duis aliquam convallis nunc proin at turpis a pede posuere	6	9	Metal
Galant	adipiscing molestie hendrerit at vulputate vitae nisl aenean lectus pellentesque eget nunc donec quis	6	7	Wood
G35	justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas tristique est et tempus semper est quam pharetra	5	11	Gold
Protege	justo maecenas rhoncus aliquam lacus morbi quis tortor id nulla ultrices aliquet maecenas leo odio condimentum id luctus nec molestie	7	11	Ruby
\.


--
-- Data for Name: kategori; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.kategori (nama, level, sub_dari) FROM stdin;
Rumah_Rumahan	2	Rumah_Rumahan
Motorik_Kasar	1	Baby_Walker
Musik_Mainan	3	Rumah_Rumahan
Motorik_Halus	1	Motorik_Halus
Baby_Walker	1	Motorik_Kasar
\.


--
-- Data for Name: kategori_item; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.kategori_item (nama_item, nama_kategori) FROM stdin;
Diamante	Rumah_Rumahan
Legacy	Rumah_Rumahan
Grand Caravan	Rumah_Rumahan
Yukon XL 2500	Rumah_Rumahan
Elantra	Rumah_Rumahan
F150	Rumah_Rumahan
Express	Rumah_Rumahan
Pajero	Rumah_Rumahan
Ranger	Rumah_Rumahan
Wrangler	Rumah_Rumahan
TL	Rumah_Rumahan
911	Motorik_Halus
Grand Cherokee	Motorik_Halus
Envoy	Motorik_Halus
Express 3500	Motorik_Halus
E-Class	Motorik_Halus
Beetle	Motorik_Halus
X6	Motorik_Halus
968	Motorik_Halus
XLR	Motorik_Halus
Dakota Club	Motorik_Halus
Boxster	Motorik_Halus
Galant	Motorik_Halus
G35	Motorik_Halus
Protege	Motorik_Halus
Diamante	Motorik_Kasar
Legacy	Motorik_Kasar
Grand Caravan	Motorik_Kasar
Yukon XL 2500	Motorik_Kasar
Elantra	Motorik_Kasar
F150	Motorik_Kasar
Express	Motorik_Kasar
Pajero	Motorik_Kasar
Ranger	Motorik_Kasar
Wrangler	Motorik_Kasar
TL	Motorik_Kasar
911	Motorik_Kasar
Grand Cherokee	Motorik_Kasar
Envoy	Motorik_Kasar
Express 3500	Motorik_Kasar
E-Class	Motorik_Kasar
Beetle	Motorik_Kasar
X6	Motorik_Kasar
968	Motorik_Kasar
XLR	Motorik_Kasar
Dakota Club	Motorik_Kasar
Boxster	Motorik_Kasar
Galant	Motorik_Kasar
G35	Motorik_Kasar
Protege	Motorik_Kasar
Diamante	Baby_Walker
Legacy	Baby_Walker
Grand Caravan	Baby_Walker
Yukon XL 2500	Baby_Walker
Elantra	Baby_Walker
F150	Baby_Walker
Express	Baby_Walker
Pajero	Baby_Walker
Ranger	Baby_Walker
Wrangler	Baby_Walker
TL	Baby_Walker
911	Baby_Walker
Grand Cherokee	Baby_Walker
Envoy	Musik_Mainan
Express 3500	Musik_Mainan
E-Class	Musik_Mainan
Beetle	Musik_Mainan
X6	Musik_Mainan
968	Musik_Mainan
XLR	Musik_Mainan
Dakota Club	Musik_Mainan
Boxster	Musik_Mainan
Galant	Musik_Mainan
G35	Musik_Mainan
Protege	Musik_Mainan
\.


--
-- Data for Name: level_keanggotaan; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.level_keanggotaan (nama_level, minimum_poin, deskripsi) FROM stdin;
bronze	500	level anda adalah bronze
silver	1000	level anda adalah silver
gold	1500	level anda adalah gold
\.


--
-- Data for Name: pemesanan; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.pemesanan (id_pemesanan, datetime_pesanan, kuantitas_barang, harga_sewa, ongkos, no_ktp_pemesan, status) FROM stdin;
P-13749887	2018-06-29 09:09:32	10	707078	10000	71-5394236	sudah_dikembalikan
P-09274864	2018-08-21 03:50:20	5	610991	10000	62-6768332	dalam_masa_sewa
P-21574182	2018-05-02 12:23:36	3	111815	10000	63-6658840	menunggu_pembayaran
P-57268075	2019-03-14 22:15:11	3	905551	10000	08-3828480	sudah_dikembalikan
P-28956503	2018-10-27 13:30:18	9	417857	10000	36-1995474	batal
P-24323334	2019-02-21 22:06:12	2	549924	10000	88-4468470	sedang_disiapkan
P-42642764	2018-09-19 00:05:27	1	473789	10000	73-3358461	menunggu_pembayaran
P-14835241	2018-05-06 21:33:55	4	266738	10000	90-0262173	sudah_dikembalikan
P-83632875	2018-07-31 17:46:18	8	996868	10000	55-6935035	batal
P-67369244	2018-06-17 01:44:26	3	898852	10000	72-6544899	sedang_dikonfirmasi
P-67410985	2018-05-30 13:37:27	7	482218	10000	36-1995474	sudah_dikembalikan
P-06974002	2019-03-03 07:21:16	9	445409	10000	80-3713705	sudah_dikembalikan
P-88000712	2018-05-14 15:35:34	7	676170	10000	31-1836523	dalam_masa_sewa
P-73683953	2018-06-30 08:04:46	1	722432	10000	38-5558539	sudah_dikembalikan
P-48637492	2018-09-23 03:50:42	1	528021	10000	85-5621510	sedang_dikirim
P-37173868	2019-01-26 04:07:20	9	878131	10000	90-0262173	sedang_disiapkan
P-44525113	2018-12-30 20:11:23	2	736758	10000	58-7751015	sedang_dikirim
P-01763785	2019-03-22 22:22:12	3	737823	10000	58-9067754	batal
P-30006976	2018-05-21 13:48:35	6	944340	10000	88-4468470	sedang_dikirim
P-03203429	2019-01-22 20:59:49	4	892346	10000	98-8557557	dalam_masa_sewa
P-66010035	2018-06-25 05:50:57	10	548156	10000	25-2116525	sedang_dikonfirmasi
P-14249818	2018-10-03 14:42:04	2	419663	10000	63-6658840	sudah_dikembalikan
P-94343818	2018-08-06 01:47:10	10	471279	10000	68-1681959	sedang_dikonfirmasi
P-56787860	2018-04-25 02:36:24	9	829047	10000	62-6768332	sedang_dikirim
P-05263928	2018-11-11 17:57:05	9	109706	10000	73-3358461	menunggu_pembayaran
P-86850772	2018-05-22 21:01:01	2	889088	10000	85-4332241	dalam_masa_sewa
P-99526739	2018-09-04 14:36:47	4	923550	10000	68-1681959	menunggu_pembayaran
P-15970375	2018-12-02 19:56:56	8	864773	10000	24-7092125	batal
P-63281370	2018-04-23 02:17:10	7	722427	10000	76-8189638	sedang_disiapkan
P-12595352	2019-02-22 12:02:20	3	196385	10000	51-1435536	sedang_dikonfirmasi
P-92190012	2018-05-04 05:50:58	4	605531	10000	62-6768332	sedang_disiapkan
P-30159675	2018-07-03 09:18:34	5	911157	10000	76-8189638	sudah_dikembalikan
P-59252325	2018-09-12 05:59:26	9	737426	10000	62-6768332	batal
P-88589615	2018-11-18 08:27:46	1	326960	10000	74-9686420	sedang_disiapkan
P-72048063	2018-06-08 09:06:24	5	180644	10000	36-1995474	batal
P-96070916	2018-07-04 10:07:23	2	776100	10000	95-3869222	dalam_masa_sewa
P-58857087	2018-08-03 01:30:38	9	965089	10000	00-4846838	menunggu_pembayaran
P-07541032	2018-09-27 00:30:20	4	429928	10000	83-2480047	sedang_dikirim
P-21146974	2018-11-01 18:34:00	8	581233	10000	45-2666102	dalam_masa_sewa
P-58960673	2018-12-19 01:27:12	6	253286	10000	73-3358461	sedang_dikonfirmasi
P-79625429	2018-06-01 09:47:32	4	961270	10000	46-3695500	sedang_dikonfirmasi
P-21204315	2019-03-18 00:55:45	2	198125	10000	36-1995474	dalam_masa_sewa
P-94366340	2018-07-27 14:13:45	7	778292	10000	61-8938466	dalam_masa_sewa
P-14876776	2018-09-04 18:09:59	3	868823	10000	91-2271079	sudah_dikembalikan
P-67216815	2018-08-31 22:56:47	5	652516	10000	05-8036652	sedang_dikirim
P-44889627	2018-12-28 15:49:26	10	113219	10000	76-4863780	menunggu_pembayaran
P-13360628	2018-05-01 20:22:25	3	738777	10000	98-8557557	sedang_dikirim
P-50389624	2018-10-25 19:36:08	10	745945	10000	10-6765373	dalam_masa_sewa
P-31282248	2018-10-28 10:37:39	4	547252	10000	22-4950259	dalam_masa_sewa
P-21081111	2018-04-21 19:36:25	1	396568	10000	88-9339984	sedang_disiapkan
\.


--
-- Data for Name: pengembalian; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.pengembalian (no_resi, id_pemesanan, metode, ongkos, tanggal, no_ktp_anggota, nama_alamat_anggota) FROM stdin;
1000	P-14835241	regular	15000	2019-02-19	90-0262173	Marah
1001	P-21146974	express	50000	2018-08-18	31-5087250	Summer
1002	P-21204315	one_day	15000	2019-03-15	38-5558539	Francesca
1003	P-63281370	express	10000	2018-08-04	47-0373803	Otto
1004	P-88000712	regular	25000	2018-08-12	90-0262173	Byron
1005	P-66010035	express	25000	2018-09-12	89-0232531	Graiden
1006	P-05263928	regular	10000	2018-12-02	00-0651073	Alfonso
1007	P-67369244	express	15000	2019-05-04	90-0262173	Nissim
1008	P-14249818	regular	10000	2018-08-02	63-6658840	Raymond
1009	P-79625429	express	15000	2018-08-29	46-3695500	Denton
1010	P-67216815	regular	10000	2018-09-21	50-2730271	Tyrone
1011	P-30006976	regular	25000	2018-11-10	51-1435536	Scarlett
1012	P-21574182	regular	15000	2019-01-04	90-0262173	Ebony
1013	P-37173868	regular	25000	2019-01-29	23-7102043	Jasper
1014	P-15970375	express	50000	2019-04-24	81-9341132	Avram
1015	P-86850772	regular	10000	2018-08-26	22-4950259	Kaseem
1016	P-12595352	express	25000	2019-08-03	51-1435536	Leonard
1017	P-14835241	regular	15000	2019-01-03	90-0262173	Sade
1018	P-30159675	express	10000	2018-07-20	21-9661851	Tyler
1019	P-28956503	regular	50000	2018-09-10	58-4832507	Gail
\.


--
-- Data for Name: pengguna; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.pengguna (no_ktp, nama_lengkap, email, tanggal_lahir, no_telp) FROM stdin;
91-2271079	Asia Rash	arash0@timesonline.co.uk	1959-04-19	4163746686
54-5414033	Domenico Brando	dbrando1@cloudflare.com	1972-09-27	5491562014
09-3873358	Cosme Pranger	cpranger2@guardian.co.uk	1967-08-29	1338467046
95-3869222	Maighdiln Philippeaux	mphilippeaux3@businesswire.com	1950-05-13	3442553122
98-8557557	Shawn Eggins	seggins4@loc.gov	1990-07-23	3144669295
45-2666102	Penni Gadie	pgadie5@pbs.org	1961-05-22	5547885374
62-6768332	Paula Syddall	psyddall6@goo.ne.jp	1988-10-19	5944293593
31-4951229	Genni Siene	gsiene7@spotify.com	1967-12-15	2251588617
74-9686420	Gleda Mulford	gmulford8@ebay.com	1978-07-31	3679652056
85-6383011	Pinchas Immins	pimmins9@nasa.gov	1957-02-17	6258209878
99-9092432	Caresa Staterfield	cstaterfielda@creativecommons.org	1995-08-20	7785771609
53-1552795	Phyllys Methuen	pmethuenb@hatena.ne.jp	1967-06-29	9728493915
85-5621510	Almira Lipmann	alipmannc@behance.net	1989-10-18	2152483594
94-1012449	Giselbert Ausiello	gausiellod@photobucket.com	1980-03-15	2495808971
05-8036652	Dreddy Abrahm	dabrahme@usa.gov	1957-12-27	1098804410
88-4468470	Sterne Elcoux	selcouxf@ebay.co.uk	1955-08-10	4707237367
08-3828480	Constanta Cromleholme	ccromleholmeg@mysql.com	1952-11-10	8234518661
80-1732128	Bevvy Skittrell	bskittrellh@usa.gov	1986-01-29	4612950157
88-4363286	Binni Dyer	bdyeri@si.edu	1950-07-27	4674096590
80-3713705	Karin Norssister	knorssisterj@51.la	1955-05-31	4254342182
85-4332241	Erhart Renault	erenaultk@gizmodo.com	1965-04-02	9155398282
75-5784519	Philly Maple	pmaplel@nymag.com	1981-12-25	9596136079
41-5923595	Tawnya Tippin	ttippinm@fda.gov	1958-07-17	9424752591
22-4570463	Tedra Burdass	tburdassn@squidoo.com	1969-02-11	2007362562
10-6765373	Camellia Varrow	cvarrowo@blogger.com	1995-12-29	4692655928
39-2398085	Arthur Cejka	acejkap@eepurl.com	1985-09-18	2167330032
99-2895129	Melania Camerello	mcamerelloq@slideshare.net	1985-07-19	6892142859
88-9339984	Caldwell Sidebotham	csidebothamr@hostgator.com	1985-12-01	9928777428
28-4726627	Barbra Gianotti	bgianottis@timesonline.co.uk	1980-09-11	9628391479
36-1995474	Vanya Pavlata	vpavlatat@tamu.edu	1999-03-01	6045058187
76-8189638	Xavier Foxley	xfoxleyu@slideshare.net	1977-12-01	6993338875
58-9067754	Annissa Greggor	agreggorv@ft.com	1974-10-20	8982272059
35-2951411	Cherida Dew	cdeww@fastcompany.com	1970-02-06	8472999414
58-7751015	Corabelle Shotboulte	cshotboultex@privacy.gov.au	1982-11-17	4883395583
99-1224681	Kristoffer Hollyer	khollyery@stumbleupon.com	1982-04-26	7263732049
97-4104338	Filbert Gateshill	fgateshillz@live.com	1945-05-20	2403217667
80-6546282	Parke Allsobrook	pallsobrook10@latimes.com	1984-02-27	5023219019
65-2762150	Winnifred Lampel	wlampel11@hubpages.com	1967-05-28	9285251396
91-8116990	Jeremy Ritchings	jritchings12@aol.com	1989-02-23	5688029071
83-2480047	Jaime Hare	jhare13@taobao.com	1969-06-07	9945887813
00-4846838	Shaun Cottrell	scottrell14@blinklist.com	1964-07-27	8788179538
87-7634375	Roana Polfer	rpolfer15@tmall.com	1947-04-30	5581450739
14-0726643	Theresa Helm	thelm16@behance.net	1965-05-12	4695357125
77-7148223	Cos O'Breen	cobreen17@dion.ne.jp	1966-02-10	3271240150
28-7864139	Bryn Loble	bloble18@cisco.com	1951-01-04	1101977760
25-2116525	Coop Blackmoor	cblackmoor19@nsw.gov.au	1979-01-06	1645756406
24-7092125	Dag Swoffer	dswoffer1a@blogger.com	1985-12-11	1865799360
72-6544899	Inness Presslee	ipresslee1b@nifty.com	1978-02-03	6939129037
18-0943382	Tuesday Deller	tdeller1c@bbc.co.uk	1957-10-16	9713798204
61-8938466	Zola Cunnington	zcunnington1d@hatena.ne.jp	1990-04-28	2141317472
88-1785178	Cchaddie Griffitt	cgriffitt1e@kickstarter.com	1978-11-16	9942111031
46-3695500	Veronique Storr	vstorr1f@businesswire.com	1973-09-27	7963272785
68-1681959	Shana Ridd	sridd1g@about.com	1961-11-06	4429290574
31-5087250	Tailor Alasdair	talasdair1h@is.gd	1999-12-04	4965243675
76-4863780	Ginelle Olyet	golyet1i@blinklist.com	1965-05-05	9153618629
50-2730271	Allayne Janacek	ajanacek1j@devhub.com	1985-07-18	8088859562
90-0262173	Cherilyn Worsnip	cworsnip1k@exblog.jp	1951-04-21	9857041781
47-0373803	Berrie Whaplington	bwhaplington1l@ehow.com	1988-11-28	5373247625
22-4950259	Cecil Bottoner	cbottoner1m@dion.ne.jp	1952-02-25	4451334813
23-7102043	Patrizia Coles	pcoles1n@ustream.tv	1958-10-11	2276647957
37-9024049	Ethel Dwerryhouse	edwerryhouse1o@rediff.com	1964-02-06	9632871794
73-3358461	Thatch Bostick	tbostick1p@list-manage.com	1951-04-09	7749149252
50-6722733	Elberta Reford	ereford1q@ask.com	1998-07-20	3292699054
21-9661851	Nevins Calver	ncalver1r@netscape.com	1999-07-29	5182788887
51-1435536	Lonee McLaverty	lmclaverty1s@uol.com.br	1995-02-16	6078998375
05-7449820	Gladi Micklewright	gmicklewright1t@instagram.com	1957-04-04	7803091498
89-0232531	Lorenzo Southorn	lsouthorn1u@hud.gov	1988-12-09	6441588192
56-9679854	Jenelle Longland	jlongland1v@weebly.com	1955-06-20	8192652221
55-6935035	Carlee Penniell	cpenniell1w@themeforest.net	1947-10-15	7139134792
31-1836523	Anette Aspy	aaspy1x@nymag.com	1997-02-28	2625134042
74-6347410	Susanne Whenham	swhenham1y@umich.edu	1955-02-17	3297409444
11-6371656	Quintana Iannetti	qiannetti1z@vinaora.com	1979-07-08	2306765405
63-6658840	Georgia Pockett	gpockett20@webnode.com	1979-01-20	5814030247
00-0651073	Wyndham Canton	wcanton21@altervista.org	1980-09-21	1655679355
03-8466469	Armando Pirot	apirot22@yahoo.com	1979-12-22	9303613803
54-3525571	Laetitia Farnon	lfarnon23@amazon.com	1999-07-08	5434458587
81-9341132	Herc Ceresa	hceresa24@dmoz.org	1980-02-28	7232679460
54-8763454	Gratia Slym	gslym25@ocn.ne.jp	1958-08-10	3907739086
91-4724879	Amby Corona	acorona26@yandex.ru	1968-08-16	9723887679
17-3223513	Frederica Costock	fcostock27@twitpic.com	1958-12-12	1614379766
38-5558539	Maure Kave	mkave28@house.gov	1964-03-03	7623663498
49-9416117	Terrye O'Shirine	toshirine29@nih.gov	1985-05-27	6435375719
38-6239730	Jakob Trewinnard	jtrewinnard2a@unicef.org	1989-10-25	2887313145
29-2122920	Jonis Aloshkin	jaloshkin2b@123-reg.co.uk	1966-10-15	8938820424
26-2106213	Neile Dawtry	ndawtry2c@ft.com	1980-10-07	9199792862
62-6138652	Hans Gamil	hgamil2d@theglobeandmail.com	1995-03-11	4424536323
25-3588974	Elston Loomes	eloomes2e@phoca.cz	1995-12-29	3783059074
58-4832507	Diane Sandyford	dsandyford2f@flickr.com	1947-01-09	8563841132
71-5394236	Mercie Farrear	mfarrear2g@ifeng.com	1961-10-06	3017806741
46-4306622	Norma Sandeson	nsandeson2h@ustream.tv	1982-04-20	7217549839
06-9997319	Mauricio Benedetti	mbenedetti2i@imgur.com	1990-10-18	2274305261
17-1240312	Bibi Perigeaux	bperigeaux2j@noaa.gov	1962-03-26	1852835708
91-8332192	Meggy Dearness	mdearness2k@geocities.jp	1952-11-23	3716472064
80-5342780	Peggy Pariss	ppariss2l@weibo.com	1971-05-25	6773348848
29-6736736	Isidora Gylle	igylle2m@ehow.com	1963-07-30	1253757113
61-5163734	Lesley Hearl	lhearl2n@bizjournals.com	1970-12-08	4423583232
64-7046981	Selle Antonik	santonik2o@foxnews.com	1988-07-22	6898988337
46-4222968	Deeanne Ousley	dousley2p@tripod.com	1961-06-16	4027119557
36-9622643	Jasper Beecker	jbeecker2q@japanpost.jp	1974-09-03	8138117240
41-1743563	Melamie Baraja	mbaraja2r@macromedia.com	1972-01-23	8497795016
\.


--
-- Data for Name: pengiriman; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.pengiriman (no_resi, id_pemesanan, metode, ongkos, tanggal, no_ktp_anggota, nama_alamat_anggota) FROM stdin;
1000	P-14835241	one_day	25000	2019-02-16	90-0262173	Marah
1001	P-05263928	one_day	50000	2018-08-14	73-3358461	Alexandra
1002	P-12595352	regular	15000	2019-01-31	51-1435536	Ainsley
1003	P-13749887	regular	50000	2018-06-30	71-5394236	Troy
1004	P-14249818	one_day	25000	2018-07-12	63-6658840	Chaney
1005	P-14835241	regular	15000	2018-09-09	90-0262173	Ariana
1006	P-21574182	express	15000	2018-05-02	63-6658840	Chaney
1007	P-31282248	one_day	25000	2018-05-04	22-4950259	Adria
1008	P-37173868	express	50000	2018-05-02	90-0262173	Ariana
1009	P-42642764	regular	50000	2018-08-06	73-3358461	Alexandra
1010	P-44889627	one_day	50000	2018-08-21	76-4863780	Martina
1011	P-58960673	one_day	15000	2018-09-05	73-3358461	Alexandra
1012	P-73683953	one_day	15000	2018-12-28	38-5558539	Francesca
1013	P-79625429	regular	15000	2019-01-16	46-3695500	Denton
1014	P-83632875	one_day	50000	2019-02-24	55-6935035	Lewis
1015	P-88000712	regular	15000	2018-05-16	31-1836523	Shay
1016	P-94343818	express	25000	2019-02-27	68-1681959	Alana
1017	P-99526739	one_day	50000	2018-07-11	68-1681959	Calvin
1018	P-94343818	regular	25000	2018-04-30	68-1681959	Alana
1019	P-73683953	express	15000	2018-05-03	38-5558539	Francesca
\.


--
-- Data for Name: status; Type: TABLE DATA; Schema: public; Owner: db2018084
--

COPY public.status (nama, deskripsi) FROM stdin;
sedang_dikirim	pesanan sedang dalam masa pengiriman
menunggu_pembayaran	menunggu pelunasan pembayaran
sudah_dikembalikan	pesanan telah dikembalikan
batal	pesanan dibatalkan
sedang_disiapkan	pesanan sedang disiapkan
dalam_masa_sewa	barang sedang di sewa
sedang_dikonfirmasi	pesanan telah dikonfirmasi
\.


--
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (no_ktp);


--
-- Name: alamat alamat_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.alamat
    ADD CONSTRAINT alamat_pkey PRIMARY KEY (no_ktp_anggota, nama);


--
-- Name: anggota anggota_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.anggota
    ADD CONSTRAINT anggota_pkey PRIMARY KEY (no_ktp);


--
-- Name: barang_dikembalikan barang_dikembalikan_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang_dikembalikan
    ADD CONSTRAINT barang_dikembalikan_pkey PRIMARY KEY (no_resi, no_urut);


--
-- Name: barang_dikirim barang_dikirim_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang_dikirim
    ADD CONSTRAINT barang_dikirim_pkey PRIMARY KEY (no_resi, no_urut);


--
-- Name: barang_pesanan barang_pesanan_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang_pesanan
    ADD CONSTRAINT barang_pesanan_pkey PRIMARY KEY (id_pemesanan, no_urut);


--
-- Name: barang barang_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang
    ADD CONSTRAINT barang_pkey PRIMARY KEY (id_barang);


--
-- Name: chat chat_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT chat_pkey PRIMARY KEY (id);


--
-- Name: info_barang_level info_barang_level_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.info_barang_level
    ADD CONSTRAINT info_barang_level_pkey PRIMARY KEY (id_barang, nama_level);


--
-- Name: item item_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_pkey PRIMARY KEY (nama);


--
-- Name: kategori_item kategori_item_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.kategori_item
    ADD CONSTRAINT kategori_item_pkey PRIMARY KEY (nama_item, nama_kategori);


--
-- Name: kategori kategori_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.kategori
    ADD CONSTRAINT kategori_pkey PRIMARY KEY (nama);


--
-- Name: level_keanggotaan level_keanggotaan_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.level_keanggotaan
    ADD CONSTRAINT level_keanggotaan_pkey PRIMARY KEY (nama_level);


--
-- Name: pemesanan pemesanan_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.pemesanan
    ADD CONSTRAINT pemesanan_pkey PRIMARY KEY (id_pemesanan);


--
-- Name: pengembalian pengembalian_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.pengembalian
    ADD CONSTRAINT pengembalian_pkey PRIMARY KEY (no_resi);


--
-- Name: pengguna pengguna_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.pengguna
    ADD CONSTRAINT pengguna_pkey PRIMARY KEY (no_ktp);


--
-- Name: pengiriman pengiriman_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.pengiriman
    ADD CONSTRAINT pengiriman_pkey PRIMARY KEY (no_resi);


--
-- Name: status status_pkey; Type: CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (nama);


--
-- Name: pemesanan pemesanan_trigger; Type: TRIGGER; Schema: public; Owner: db2018084
--

CREATE TRIGGER pemesanan_trigger AFTER INSERT OR UPDATE ON public.pemesanan FOR EACH ROW EXECUTE PROCEDURE public.func_kondisi_barang();


--
-- Name: anggota update_level; Type: TRIGGER; Schema: public; Owner: db2018084
--

CREATE TRIGGER update_level AFTER UPDATE ON public.anggota FOR EACH ROW EXECUTE PROCEDURE public.determine_level();


--
-- Name: barang update_point_deposit; Type: TRIGGER; Schema: public; Owner: db2018084
--

CREATE TRIGGER update_point_deposit AFTER INSERT ON public.barang FOR EACH ROW EXECUTE PROCEDURE public.calculate_point_deposit();


--
-- Name: barang_pesanan update_point_order; Type: TRIGGER; Schema: public; Owner: db2018084
--

CREATE TRIGGER update_point_order AFTER INSERT ON public.barang_pesanan FOR EACH ROW EXECUTE PROCEDURE public.calculate_point_order();


--
-- Name: barang_pesanan update_rent_price; Type: TRIGGER; Schema: public; Owner: db2018084
--

CREATE TRIGGER update_rent_price AFTER INSERT ON public.barang_pesanan FOR EACH ROW EXECUTE PROCEDURE public.calculate_rent_price();


--
-- Name: pengiriman update_shipping_price; Type: TRIGGER; Schema: public; Owner: db2018084
--

CREATE TRIGGER update_shipping_price AFTER INSERT ON public.pengiriman FOR EACH ROW EXECUTE PROCEDURE public.calculate_shipping_price();


--
-- Name: admin admin_no_ktp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_no_ktp_fkey FOREIGN KEY (no_ktp) REFERENCES public.pengguna(no_ktp) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: alamat alamat_no_ktp_anggota_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.alamat
    ADD CONSTRAINT alamat_no_ktp_anggota_fkey FOREIGN KEY (no_ktp_anggota) REFERENCES public.anggota(no_ktp) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: anggota anggota_level_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.anggota
    ADD CONSTRAINT anggota_level_fkey FOREIGN KEY (level) REFERENCES public.level_keanggotaan(nama_level) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: anggota anggota_no_ktp_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.anggota
    ADD CONSTRAINT anggota_no_ktp_fkey FOREIGN KEY (no_ktp) REFERENCES public.pengguna(no_ktp) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: barang_dikembalikan barang_dikembalikan_id_barang_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang_dikembalikan
    ADD CONSTRAINT barang_dikembalikan_id_barang_fkey FOREIGN KEY (id_barang) REFERENCES public.barang(id_barang) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: barang_dikembalikan barang_dikembalikan_no_resi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang_dikembalikan
    ADD CONSTRAINT barang_dikembalikan_no_resi_fkey FOREIGN KEY (no_resi) REFERENCES public.pengembalian(no_resi) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: barang_dikirim barang_dikirim_id_barang_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang_dikirim
    ADD CONSTRAINT barang_dikirim_id_barang_fkey FOREIGN KEY (id_barang) REFERENCES public.barang(id_barang) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: barang_dikirim barang_dikirim_no_resi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang_dikirim
    ADD CONSTRAINT barang_dikirim_no_resi_fkey FOREIGN KEY (no_resi) REFERENCES public.pengiriman(no_resi) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: barang barang_nama_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang
    ADD CONSTRAINT barang_nama_item_fkey FOREIGN KEY (nama_item) REFERENCES public.item(nama) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: barang barang_no_ktp_penyewa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang
    ADD CONSTRAINT barang_no_ktp_penyewa_fkey FOREIGN KEY (no_ktp_penyewa) REFERENCES public.anggota(no_ktp) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: barang_pesanan barang_pesanan_id_barang_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang_pesanan
    ADD CONSTRAINT barang_pesanan_id_barang_fkey FOREIGN KEY (id_barang) REFERENCES public.barang(id_barang) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: barang_pesanan barang_pesanan_id_pemesanan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang_pesanan
    ADD CONSTRAINT barang_pesanan_id_pemesanan_fkey FOREIGN KEY (id_pemesanan) REFERENCES public.pemesanan(id_pemesanan) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: barang_pesanan barang_pesanan_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.barang_pesanan
    ADD CONSTRAINT barang_pesanan_status_fkey FOREIGN KEY (status) REFERENCES public.status(nama) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: chat chat_no_ktp_admin_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT chat_no_ktp_admin_fkey FOREIGN KEY (no_ktp_admin) REFERENCES public.admin(no_ktp) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: chat chat_no_ktp_anggota_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.chat
    ADD CONSTRAINT chat_no_ktp_anggota_fkey FOREIGN KEY (no_ktp_anggota) REFERENCES public.anggota(no_ktp) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: info_barang_level info_barang_level_id_barang_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.info_barang_level
    ADD CONSTRAINT info_barang_level_id_barang_fkey FOREIGN KEY (id_barang) REFERENCES public.barang(id_barang) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: info_barang_level info_barang_level_nama_level_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.info_barang_level
    ADD CONSTRAINT info_barang_level_nama_level_fkey FOREIGN KEY (nama_level) REFERENCES public.level_keanggotaan(nama_level) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: kategori_item kategori_item_nama_item_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.kategori_item
    ADD CONSTRAINT kategori_item_nama_item_fkey FOREIGN KEY (nama_item) REFERENCES public.item(nama) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: kategori_item kategori_item_nama_kategori_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.kategori_item
    ADD CONSTRAINT kategori_item_nama_kategori_fkey FOREIGN KEY (nama_kategori) REFERENCES public.kategori(nama) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: kategori kategori_sub_dari_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.kategori
    ADD CONSTRAINT kategori_sub_dari_fkey FOREIGN KEY (sub_dari) REFERENCES public.kategori(nama) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pemesanan pemesanan_no_ktp_pemesan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.pemesanan
    ADD CONSTRAINT pemesanan_no_ktp_pemesan_fkey FOREIGN KEY (no_ktp_pemesan) REFERENCES public.anggota(no_ktp) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pemesanan pemesanan_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.pemesanan
    ADD CONSTRAINT pemesanan_status_fkey FOREIGN KEY (status) REFERENCES public.status(nama) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pengembalian pengembalian_id_pemesanan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.pengembalian
    ADD CONSTRAINT pengembalian_id_pemesanan_fkey FOREIGN KEY (id_pemesanan) REFERENCES public.pemesanan(id_pemesanan) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pengembalian pengembalian_no_ktp_anggota_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.pengembalian
    ADD CONSTRAINT pengembalian_no_ktp_anggota_fkey FOREIGN KEY (no_ktp_anggota, nama_alamat_anggota) REFERENCES public.alamat(no_ktp_anggota, nama) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pengembalian pengembalian_no_resi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.pengembalian
    ADD CONSTRAINT pengembalian_no_resi_fkey FOREIGN KEY (no_resi) REFERENCES public.pengiriman(no_resi) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pengiriman pengiriman_id_pemesanan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.pengiriman
    ADD CONSTRAINT pengiriman_id_pemesanan_fkey FOREIGN KEY (id_pemesanan) REFERENCES public.pemesanan(id_pemesanan) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pengiriman pengiriman_no_ktp_anggota_fkey; Type: FK CONSTRAINT; Schema: public; Owner: db2018084
--

ALTER TABLE ONLY public.pengiriman
    ADD CONSTRAINT pengiriman_no_ktp_anggota_fkey FOREIGN KEY (no_ktp_anggota, nama_alamat_anggota) REFERENCES public.alamat(no_ktp_anggota, nama) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

