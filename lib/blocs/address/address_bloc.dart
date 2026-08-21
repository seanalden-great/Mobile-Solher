import 'package:flutter_bloc/flutter_bloc.dart';
import 'address_event.dart';
import 'address_state.dart';
import '../../repositories/address_repository.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository addressRepository;

  AddressBloc({required this.addressRepository}) : super(AddressInitial()) {
    // 1. Ambil daftar alamat
    on<FetchAddresses>((event, emit) async {
      emit(AddressLoading());
      try {
        final addresses = await addressRepository.getAddresses();
        emit(AddressLoaded(addresses));
      } catch (e) {
        emit(AddressError(e.toString()));
      }
    });

    // 2. Tambah alamat baru
    on<CreateAddressEvent>((event, emit) async {
      emit(AddressLoading());
      try {
        await addressRepository.createAddress(event.address);
        emit(const AddressActionSuccess('Alamat berhasil ditambahkan.'));
        add(FetchAddresses()); // Segarkan daftar alamat
      } catch (e) {
        emit(AddressError(e.toString()));
      }
    });

    // 3. Perbarui alamat
    on<UpdateAddressEvent>((event, emit) async {
      emit(AddressLoading());
      try {
        await addressRepository.updateAddress(event.id, event.address);
        emit(const AddressActionSuccess('Alamat berhasil diperbarui.'));
        add(FetchAddresses()); // Segarkan daftar alamat
      } catch (e) {
        emit(AddressError(e.toString()));
      }
    });

    // 4. Hapus alamat
    on<DeleteAddressEvent>((event, emit) async {
      emit(AddressLoading());
      try {
        await addressRepository.deleteAddress(event.id);
        emit(const AddressActionSuccess('Alamat berhasil dihapus.'));
        add(FetchAddresses()); // Segarkan daftar alamat
      } catch (e) {
        emit(AddressError(e.toString()));
      }
    });
  }
}
