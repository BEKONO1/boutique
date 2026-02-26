<form action="">
    <div class="offcanvas offcanvas-end" tabindex="-1" id="offcanvasEditProducts"
        aria-labelledby="offcanvasEditProductsLabel" style="--bs-offcanvas-width: 750px;">
        <div class="offcanvas-header border d-block">
            <div class="d-flex justify-content-between align-items-center gap-2 w-100 mb-2">
                <h3 class="fw-bold fs-18 mb-0">{{ translate('Edit_Products') }}</h3>
                <button type="button" class="btn btn-circle bg-section text-dark fs-10" style="--size: 1.5rem;" data-bs-dismiss="offcanvas" aria-label="Close">
                    <i class="fi fi-rr-cross"></i>
                </button>
            </div>
            <div class="d-flex align-items-center gap-4">
                <div class="d-flex gap-1 align-items-center">
                    <h4 class="mb-0">{{ translate('Order') }} #100065</h4>
                    <span class="badge text-bg-info badge-info">{{ translate('Pending') }}</span>
                </div>
                <div>
                    <h4 class="mb-0"><span class="fw-normal">{{ translate('Order_Placed') }} :</span> <span>05 Oct 2024 06:31 pm</span></h4>
                </div>
            </div>
        </div>
        <div class="offcanvas-body">
            <div class="search-form mb-3">
                <button type="button" class="btn px-3 inset-inline-start-0 inset-inline-end-auto"><i class="fi fi-rr-search"></i>
                </button>
                <input type="search" class="form-control ps-40"
                    placeholder="{{ translate('search_by_product_name_or_bar_code_and_click_or_press_enter_to_add') }}">
            </div>
            <h3 class="mb-3">
                {{ translate('Products_List') }}
                <span class="badge text-dark bg-body-secondary fw-semibold rounded-50">3</span>
            </h3>
            <div class="table-responsive">
                <table class="table table-hover table-borderless align-middle td-padding-sm">
                    <thead class="text-capitalize">
                        <tr>
                            <th>SL</th>
                            <th>{{ translate('Item_List') }}</th>
                            <th class="text-center">{{ translate('Qty') }}</th>
                            <th class="text-end">{{ translate('Total') }}</th>
                            <th class="text-center">{{ translate('Action') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>1</td>
                            <td>
                                <div class="media align-items-center gap-2">
                                    <img class="avatar avatar-50 rounded img-fit"
                                                 src="{{ getStorageImages(path:$detail?->productAllStatus?->thumbnail_full_url, type: 'backend-product') }}"
                                                 alt="{{translate('image_Description')}}">
                                    <div class="media-body d-flex flex-column gap-1 fs-12">
                                        <div class="max-w-200 line-1">
                                            B39 Bluetooth 5.0 Headphone Ear Shape Wireless Headset phone Ear Shape 
                                        </div>
                                        <div class="d-flex gap-2 align-items-center lh-1">
                                            <span class="text-body">{{ translate('Unit_Price') }}</span> : <span>129.40$</span>
                                        </div>
                                        <div class="d-flex gap-2 align-items-center lh-1">
                                            <span class="text-body">{{ translate('Unit_Price') }}</span> : <span>129.40$</span>
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="qty-input-group form-control w-max-content d-flex gap-2 align-items-center">
                                    <button type="button" class="qty-count" data-action="minus" type="button">-</button>
                                    <input class="product-qty text-center" type="number" name="product-qty" min="1" max="10" value="5">
                                    <button class="qty-count" data-action="plus" type="button">+</button>
                                </div>
                            </td>
                            <td class="text-end">125.00$</td>
                            <td>
                                <div class="d-flex justify-content-center gap-3">
                                    <a href="javascript:" class="btn btn-danger rounded-circle icon-btn">
                                        <i class="fi fi-rr-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <tr class="table--primary">
                            <td>1</td>
                            <td>
                                <div class="media align-items-center gap-2">
                                    <img class="avatar avatar-50 rounded img-fit"
                                                 src="{{ getStorageImages(path:$detail?->productAllStatus?->thumbnail_full_url, type: 'backend-product') }}"
                                                 alt="{{translate('image_Description')}}">
                                    <div class="media-body d-flex flex-column gap-1 fs-12">
                                        <div class="max-w-200 line-1">
                                            B39 Bluetooth 5.0 Headphone Ear Shape Wireless Headset phone Ear Shape 
                                        </div>
                                        <div class="d-flex gap-2 align-items-center lh-1">
                                            <span class="text-body">{{ translate('Unit_Price') }}</span> : <span>129.40$</span>
                                        </div>
                                        <div class="d-flex gap-2 align-items-center lh-1">
                                            <span class="text-body">{{ translate('Unit_Price') }}</span> : <span>129.40$</span>
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="qty-input-group form-control w-max-content d-flex gap-2 align-items-center">
                                    <button type="button" class="qty-count" data-action="minus" type="button">-</button>
                                    <input class="product-qty text-center" type="number" name="product-qty" min="1" max="10" value="5">
                                    <button class="qty-count" data-action="plus" type="button">+</button>
                                </div>
                            </td>
                            <td class="text-end">125.00$</td>
                            <td>
                                <div class="d-flex justify-content-center gap-3">
                                    <a href="javascript:" class="btn btn-danger rounded-circle icon-btn">
                                        <i class="fi fi-rr-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <tr class="table--danger">
                            <td>1</td>
                            <td>
                                <div class="media align-items-center gap-2">
                                    <img class="avatar avatar-50 rounded img-fit"
                                                 src="{{ getStorageImages(path:$detail?->productAllStatus?->thumbnail_full_url, type: 'backend-product') }}"
                                                 alt="{{translate('image_Description')}}">
                                    <div class="media-body d-flex flex-column gap-1 fs-12">
                                        <div class="max-w-200 line-1">
                                            B39 Bluetooth 5.0 Headphone Ear Shape Wireless Headset phone Ear Shape 
                                        </div>
                                        <div class="d-flex gap-2 align-items-center lh-1">
                                            <span class="text-body">{{ translate('Unit_Price') }}</span> : <span>129.40$</span>
                                        </div>
                                        <div class="d-flex gap-2 align-items-center lh-1">
                                            <span class="text-body">{{ translate('Unit_Price') }}</span> : <span>129.40$</span>
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="qty-input-group form-control w-max-content d-flex gap-2 align-items-center">
                                    <button type="button" class="qty-count" data-action="minus" type="button">-</button>
                                    <input class="product-qty text-center" type="number" name="product-qty" min="1" max="10" value="5">
                                    <button class="qty-count" data-action="plus" type="button">+</button>
                                </div>
                            </td>
                            <td class="text-end">125.00$</td>
                            <td>
                                <div class="d-flex justify-content-center gap-3">
                                    <a href="javascript:" class="btn btn-danger rounded-circle icon-btn">
                                        <i class="fi fi-rr-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <div class="offcanvas-footer shadow-popup">
            <div class="d-flex justify-content-end align-items-center gap-3 bg-white px-4 py-3">
                <button type="reset" class="btn btn-secondary min-w-120" data-bs-dismiss="offcanvas">{{ translate('Cancel') }}</button>
                <button type="submit" class="btn btn-primary min-w-120">{{ translate('Update_Cart') }}</button>
            </div>
        </div>
    </div>
</form>
